create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  name text not null default '',
  email text not null unique,
  role text not null default 'user' check (role in ('user', 'admin')),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  product_name text not null,
  specification text not null default '',
  category text not null check (category in ('Electric', 'Electronic')),
  code text not null unique,
  image_url text,
  quantity_available integer not null default 0 check (quantity_available >= 0),
  is_available boolean not null default true,
  price numeric(10, 2) not null default 0 check (price >= 0),
  created_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.purchases (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  product_id uuid not null references public.products (id) on delete restrict,
  product_name text not null,
  quantity_bought integer not null check (quantity_bought > 0),
  total_amount numeric(10, 2) not null check (total_amount >= 0),
  purchase_date timestamptz not null default timezone('utc', now())
);

create table if not exists public.inventory_activity (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null unique references public.products (id) on delete cascade,
  item_name text not null,
  item_code text not null,
  category text not null check (category in ('Electric', 'Electronic')),
  assigned_to_name text not null default 'No User Assigned',
  assigned_role text not null default 'Unspecified',
  contact text not null default '',
  taken_at timestamptz,
  returned_at timestamptz,
  status text not null default 'Not Returned'
    check (status in ('Not Returned', 'Returned', 'Overdue')),
  is_returnable boolean,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create or replace function public.is_admin(check_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles
    where id = check_user_id
      and role = 'admin'
  );
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, name, email, role)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data ->> 'name',
      new.raw_user_meta_data ->> 'full_name',
      split_part(coalesce(new.email, ''), '@', 1),
      'User'
    ),
    coalesce(new.email, ''),
    'user'
  )
  on conflict (id) do update
  set
    name = excluded.name,
    email = excluded.email,
    updated_at = timezone('utc', now());

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create or replace function public.sync_is_available()
returns trigger
language plpgsql
as $$
begin
  new.is_available := (new.quantity_available > 0);

  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists products_set_updated_at on public.products;
create trigger products_set_updated_at
before update on public.products
for each row execute function public.set_updated_at();

drop trigger if exists products_sync_is_available on public.products;
create trigger products_sync_is_available
before insert or update on public.products
for each row execute function public.sync_is_available();

drop trigger if exists inventory_activity_set_updated_at on public.inventory_activity;
create trigger inventory_activity_set_updated_at
before update on public.inventory_activity
for each row execute function public.set_updated_at();

create or replace function public.sync_inventory_activity_product_snapshot()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  update public.inventory_activity
  set
    item_name = new.product_name,
    item_code = new.code,
    category = new.category,
    updated_at = timezone('utc', now())
  where product_id = new.id;

  return new;
end;
$$;

drop trigger if exists products_sync_inventory_activity on public.products;
create trigger products_sync_inventory_activity
after update of product_name, code, category on public.products
for each row execute function public.sync_inventory_activity_product_snapshot();

create or replace function public.sync_current_profile(
  p_name text,
  p_email text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  insert into public.profiles (id, name, email, role)
  values (
    auth.uid(),
    coalesce(nullif(trim(p_name), ''), 'User'),
    coalesce(nullif(trim(p_email), ''), ''),
    'user'
  )
  on conflict (id) do update
  set
    name = excluded.name,
    email = excluded.email,
    updated_at = timezone('utc', now());
end;
$$;

create or replace function public.purchase_product(
  p_product_id uuid,
  p_user_id uuid,
  p_quantity integer
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_product public.products%rowtype;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  if auth.uid() <> p_user_id and not public.is_admin(auth.uid()) then
    raise exception 'You can only purchase for your own account';
  end if;

  if p_quantity is null or p_quantity <= 0 then
    raise exception 'Quantity must be greater than zero';
  end if;

  select *
  into v_product
  from public.products
  where id = p_product_id
  for update;

  if not found then
    raise exception 'Product not found';
  end if;

  if v_product.quantity_available < p_quantity then
    raise exception 'Not enough stock available';
  end if;

  if not exists (select 1 from public.profiles where id = p_user_id) then
    raise exception 'User profile not found';
  end if;

  update public.products
  set
    quantity_available = quantity_available - p_quantity,
    updated_at = timezone('utc', now())
  where id = p_product_id;

  insert into public.purchases (
    user_id,
    product_id,
    product_name,
    quantity_bought,
    total_amount
  )
  values (
    p_user_id,
    p_product_id,
    v_product.product_name,
    p_quantity,
    (v_product.price * p_quantity)::numeric(10, 2)
  );
end;
$$;

grant execute on function public.is_admin(uuid) to authenticated;
grant execute on function public.sync_current_profile(text, text) to authenticated;
grant execute on function public.purchase_product(uuid, uuid, integer) to authenticated;

alter table public.profiles enable row level security;
alter table public.products enable row level security;
alter table public.purchases enable row level security;
alter table public.inventory_activity enable row level security;

drop policy if exists "Profiles are readable by owners and admins" on public.profiles;
create policy "Profiles are readable by owners and admins"
on public.profiles
for select
to authenticated
using (auth.uid() = id or public.is_admin(auth.uid()));

drop policy if exists "Products are readable by authenticated users" on public.products;
create policy "Products are readable by authenticated users"
on public.products
for select
to authenticated
using (true);

drop policy if exists "Products are writable by admins" on public.products;
create policy "Products are writable by admins"
on public.products
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

drop policy if exists "Purchases are readable by owners and admins" on public.purchases;
create policy "Purchases are readable by owners and admins"
on public.purchases
for select
to authenticated
using (auth.uid() = user_id or public.is_admin(auth.uid()));

drop policy if exists "Inventory activity is manageable by admins" on public.inventory_activity;
create policy "Inventory activity is manageable by admins"
on public.inventory_activity
for all
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));
