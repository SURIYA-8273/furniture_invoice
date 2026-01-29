-- ============================================
-- Furniture Billing App - Supabase Migration
-- ============================================
-- This script creates all necessary tables, indexes, triggers, and policies
-- for the backup system.

-- ============================================
-- 1. BILLS TABLE (Main Invoice Table)
-- ============================================

CREATE TABLE IF NOT EXISTS bills (
  -- Primary Key
  id TEXT PRIMARY KEY,
  
  -- Invoice Details
  invoice_number TEXT NOT NULL UNIQUE,
  customer_name TEXT,
  
  -- Financial Details
  grand_total DECIMAL(10, 2) NOT NULL,
  paid_amount DECIMAL(10, 2) DEFAULT 0.0,
  balance_amount DECIMAL(10, 2) NOT NULL,
  
  -- Status
  status TEXT NOT NULL CHECK (status IN ('paid', 'partial', 'unpaid')),
  
  -- Timestamps
  invoice_date TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Backup Metadata
  last_synced_at TIMESTAMPTZ DEFAULT NOW(),
  sync_status TEXT DEFAULT 'synced' CHECK (sync_status IN ('synced', 'pending', 'error'))
);

-- Indexes for bills table
CREATE INDEX IF NOT EXISTS idx_bills_invoice_number ON bills(invoice_number);
CREATE INDEX IF NOT EXISTS idx_bills_invoice_date ON bills(invoice_date DESC);
CREATE INDEX IF NOT EXISTS idx_bills_status ON bills(status);
CREATE INDEX IF NOT EXISTS idx_bills_updated_at ON bills(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_bills_sync_status ON bills(sync_status);

-- ============================================
-- 2. BILL_ITEMS TABLE (Invoice Line Items)
-- ============================================

CREATE TABLE IF NOT EXISTS bill_items (
  -- Primary Key
  id TEXT PRIMARY KEY,
  
  -- Foreign Key
  bill_id TEXT NOT NULL REFERENCES bills(id) ON DELETE CASCADE,
  
  -- Product Details
  product_name TEXT NOT NULL,
  size TEXT NOT NULL,
  
  -- Quantity & Measurements
  length DECIMAL(10, 2) NOT NULL,
  quantity INTEGER NOT NULL,
  total_length DECIMAL(10, 2) NOT NULL,
  
  -- Pricing
  rate DECIMAL(10, 2) NOT NULL,
  total_amount DECIMAL(10, 2) NOT NULL,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for bill_items table
CREATE INDEX IF NOT EXISTS idx_bill_items_bill_id ON bill_items(bill_id);
CREATE INDEX IF NOT EXISTS idx_bill_items_product_name ON bill_items(product_name);

-- ============================================
-- 3. PAYMENT_HISTORY TABLE (Payment Records)
-- ============================================

CREATE TABLE IF NOT EXISTS payment_history (
  -- Primary Key
  id TEXT PRIMARY KEY,
  
  -- Foreign Key
  invoice_id TEXT REFERENCES bills(id) ON DELETE SET NULL,
  
  -- Payment Details
  payment_date TIMESTAMPTZ NOT NULL,
  paid_amount DECIMAL(10, 2) NOT NULL,
  payment_mode TEXT NOT NULL CHECK (payment_mode IN ('cash', 'card', 'upi', 'bank_transfer', 'cheque', 'other')),
  
  -- Balance Tracking
  previous_due DECIMAL(10, 2) NOT NULL,
  remaining_due DECIMAL(10, 2) NOT NULL,
  
  -- Additional Info
  notes TEXT,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Backup Metadata
  last_synced_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for payment_history table
CREATE INDEX IF NOT EXISTS idx_payment_history_invoice_id ON payment_history(invoice_id);
CREATE INDEX IF NOT EXISTS idx_payment_history_payment_date ON payment_history(payment_date DESC);
CREATE INDEX IF NOT EXISTS idx_payment_history_payment_mode ON payment_history(payment_mode);

-- ============================================
-- 4. BACKUP_LOGS TABLE (Backup Activity Tracking)
-- ============================================

CREATE TABLE IF NOT EXISTS backup_logs (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Backup Details
  backup_type TEXT NOT NULL CHECK (backup_type IN ('automatic', 'manual')),
  backup_status TEXT NOT NULL CHECK (backup_status IN ('running', 'success', 'partial', 'failed')),
  
  -- Statistics
  bills_synced INTEGER DEFAULT 0,
  bills_failed INTEGER DEFAULT 0,
  payments_synced INTEGER DEFAULT 0,
  payments_failed INTEGER DEFAULT 0,
  
  -- Error Information
  error_message TEXT,
  error_details JSONB,
  
  -- Timestamps
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  
  -- Duration (in seconds)
  duration_seconds INTEGER
);

-- Indexes for backup_logs table
CREATE INDEX IF NOT EXISTS idx_backup_logs_backup_type ON backup_logs(backup_type);
CREATE INDEX IF NOT EXISTS idx_backup_logs_started_at ON backup_logs(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_backup_logs_backup_status ON backup_logs(backup_status);

-- ============================================
-- 5. TRIGGERS
-- ============================================

-- Auto-update updated_at timestamp for bills table
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_bills_updated_at ON bills;
CREATE TRIGGER update_bills_updated_at
  BEFORE UPDATE ON bills
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 6. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================
-- Note: Adjust these policies based on your authentication setup
-- For now, allowing all operations for authenticated users

-- Enable RLS on all tables
ALTER TABLE bills ENABLE ROW LEVEL SECURITY;
ALTER TABLE bill_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE backup_logs ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow all for users" ON bills;
DROP POLICY IF EXISTS "Enable access for all users" ON bills;
DROP POLICY IF EXISTS "Allow all for users" ON bill_items;
DROP POLICY IF EXISTS "Enable access for all users" ON bill_items;
DROP POLICY IF EXISTS "Allow all for users" ON payment_history;
DROP POLICY IF EXISTS "Enable access for all users" ON payment_history;
DROP POLICY IF EXISTS "Allow all for users" ON backup_logs;
DROP POLICY IF EXISTS "Enable access for all users" ON backup_logs;

-- Create policies for everyone (anon and authenticated)
-- Note: In a production environment with sensitive data, you should restrict this.
-- For this billing app, we allow access via the anon/service key.
CREATE POLICY "Enable access for all users" ON bills
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Enable access for all users" ON bill_items
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Enable access for all users" ON payment_history
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Enable access for all users" ON backup_logs
  FOR ALL USING (true) WITH CHECK (true);

-- ============================================
-- 7. COMMENTS (Documentation)
-- ============================================

COMMENT ON TABLE bills IS 'Main invoice/bill table storing all billing information';
COMMENT ON TABLE bill_items IS 'Line items for each bill with product details and pricing';
COMMENT ON TABLE payment_history IS 'Payment records linked to invoices';
COMMENT ON TABLE backup_logs IS 'Tracks all backup operations for monitoring and debugging';

-- ============================================
-- Migration Complete
-- ============================================

CREATE TABLE deleted_invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- Fixed: using gen_random_uuid() instead of uuid_generate_v4() which requires extension
    invoice_id TEXT NOT NULL,
    deleted_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- 8. DELETED INVOICES RLS
-- ============================================

ALTER TABLE deleted_invoices ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all for users" ON deleted_invoices;
DROP POLICY IF EXISTS "Enable access for all users" ON deleted_invoices;

CREATE POLICY "Enable access for all users" ON deleted_invoices
  FOR ALL USING (true) WITH CHECK (true);

