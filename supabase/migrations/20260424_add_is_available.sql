-- Migration: add explicit is_available column to products
-- Run this in the Supabase SQL Editor (Dashboard → SQL Editor → New query)

-- 1. Add the column (defaults to true so existing rows are unaffected)
ALTER TABLE public.products
  ADD COLUMN IF NOT EXISTS is_available boolean NOT NULL DEFAULT true;

-- 2. Backfill: mark rows with stock as available and zero stock as unavailable
UPDATE public.products
  SET is_available = (quantity_available > 0);

-- 3. Keep is_available fully aligned with quantity_available.
CREATE OR REPLACE FUNCTION public.sync_is_available()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.is_available := (NEW.quantity_available > 0);
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS products_sync_is_available ON public.products;
CREATE TRIGGER products_sync_is_available
BEFORE INSERT OR UPDATE ON public.products
FOR EACH ROW EXECUTE FUNCTION public.sync_is_available();
