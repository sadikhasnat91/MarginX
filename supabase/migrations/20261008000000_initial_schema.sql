-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- 1. PROFILES
-- ==========================================
CREATE TABLE profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

-- Function to handle new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email)
  VALUES (new.id, new.email);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ==========================================
-- 2. BUSINESSES
-- ==========================================
CREATE TABLE businesses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID REFERENCES profiles(id) NOT NULL,
    name TEXT NOT NULL,
    category TEXT,
    monthly_order_volume TEXT,
    selling_channel TEXT,
    currency TEXT DEFAULT 'BDT',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE businesses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own businesses" ON businesses FOR SELECT USING (auth.uid() = owner_id);
CREATE POLICY "Users can insert own businesses" ON businesses FOR INSERT WITH CHECK (auth.uid() = owner_id);
CREATE POLICY "Users can update own businesses" ON businesses FOR UPDATE USING (auth.uid() = owner_id);

-- ==========================================
-- 3. PRODUCTS
-- ==========================================
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    sku TEXT,
    category TEXT,
    selling_price NUMERIC(12,2) DEFAULT 0,
    product_cost NUMERIC(12,2) DEFAULT 0,
    packaging_cost NUMERIC(12,2) DEFAULT 0,
    default_discount NUMERIC(12,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their business products" ON products FOR SELECT 
  USING (business_id IN (SELECT id FROM businesses WHERE owner_id = auth.uid()));
CREATE POLICY "Users can insert their business products" ON products FOR INSERT 
  WITH CHECK (business_id IN (SELECT id FROM businesses WHERE owner_id = auth.uid()));
CREATE POLICY "Users can update their business products" ON products FOR UPDATE 
  USING (business_id IN (SELECT id FROM businesses WHERE owner_id = auth.uid()));
CREATE POLICY "Users can delete their business products" ON products FOR DELETE 
  USING (business_id IN (SELECT id FROM businesses WHERE owner_id = auth.uid()));

-- ==========================================
-- 4. ORDERS
-- ==========================================
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE NOT NULL,
    order_id_custom TEXT, -- e.g., MX1024
    customer_name TEXT,
    phone TEXT,
    status TEXT DEFAULT 'Pending', -- Pending, Confirmed, Shipped, Delivered, Returned, Cancelled, RTO
    order_date TIMESTAMPTZ DEFAULT NOW(),
    delivery_date TIMESTAMPTZ,
    courier TEXT,
    
    -- Financials per order (for historical snapshot)
    selling_price NUMERIC(12,2) DEFAULT 0,
    discount NUMERIC(12,2) DEFAULT 0,
    product_cost NUMERIC(12,2) DEFAULT 0,
    courier_cost NUMERIC(12,2) DEFAULT 0,
    packaging_cost NUMERIC(12,2) DEFAULT 0,
    ad_allocation NUMERIC(12,2) DEFAULT 0,
    payment_fee NUMERIC(12,2) DEFAULT 0,
    return_cost NUMERIC(12,2) DEFAULT 0,
    other_cost NUMERIC(12,2) DEFAULT 0,
    
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their business orders" ON orders FOR SELECT 
  USING (business_id IN (SELECT id FROM businesses WHERE owner_id = auth.uid()));
CREATE POLICY "Users can insert their business orders" ON orders FOR INSERT 
  WITH CHECK (business_id IN (SELECT id FROM businesses WHERE owner_id = auth.uid()));
CREATE POLICY "Users can update their business orders" ON orders FOR UPDATE 
  USING (business_id IN (SELECT id FROM businesses WHERE owner_id = auth.uid()));
CREATE POLICY "Users can delete their business orders" ON orders FOR DELETE 
  USING (business_id IN (SELECT id FROM businesses WHERE owner_id = auth.uid()));

-- ==========================================
-- 5. ORDER ITEMS (Many-to-Many between Orders and Products)
-- ==========================================
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    quantity INTEGER DEFAULT 1,
    unit_price NUMERIC(12,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their order items" ON order_items FOR SELECT 
  USING (order_id IN (SELECT id FROM orders WHERE business_id IN (SELECT id FROM businesses WHERE owner_id = auth.uid())));
CREATE POLICY "Users can insert their order items" ON order_items FOR INSERT 
  WITH CHECK (order_id IN (SELECT id FROM orders WHERE business_id IN (SELECT id FROM businesses WHERE owner_id = auth.uid())));
CREATE POLICY "Users can update their order items" ON order_items FOR UPDATE 
  USING (order_id IN (SELECT id FROM orders WHERE business_id IN (SELECT id FROM businesses WHERE owner_id = auth.uid())));
CREATE POLICY "Users can delete their order items" ON order_items FOR DELETE 
  USING (order_id IN (SELECT id FROM orders WHERE business_id IN (SELECT id FROM businesses WHERE owner_id = auth.uid())));

-- ==========================================
-- 6. EXPENSES
-- ==========================================
CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    category TEXT NOT NULL, -- Advertising, Courier, Packaging, Salary, Rent, Software, Payment Fee, Other
    date DATE NOT NULL,
    description TEXT,
    attachment_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their business expenses" ON expenses FOR SELECT 
  USING (business_id IN (SELECT id FROM businesses WHERE owner_id = auth.uid()));
CREATE POLICY "Users can insert their business expenses" ON expenses FOR INSERT 
  WITH CHECK (business_id IN (SELECT id FROM businesses WHERE owner_id = auth.uid()));
CREATE POLICY "Users can update their business expenses" ON expenses FOR UPDATE 
  USING (business_id IN (SELECT id FROM businesses WHERE owner_id = auth.uid()));
CREATE POLICY "Users can delete their business expenses" ON expenses FOR DELETE 
  USING (business_id IN (SELECT id FROM businesses WHERE owner_id = auth.uid()));

-- Automatically update updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_businesses_updated_at BEFORE UPDATE ON businesses FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON expenses FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
