-- ================================================= 1. ENUMS =================================================
CREATE TYPE public.todo_priority AS ENUM ('undefined', 'low', 'medium', 'high', 'urgent');

CREATE TYPE public.todo_status AS ENUM (
    'pending',
    'in_progress',
    'completed',
    'cancelled'
);

CREATE TYPE public.recurrence_pattern AS ENUM ('once', 'daily', 'weekday', 'custom');

-- ================================================= 2. TABLES =================================================
-- TABLE: TODOS 
CREATE TABLE
    IF NOT EXISTS "public"."todos" (
        "id" UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        "user_id" UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
        "title" VARCHAR(256) NOT NULL DEFAULT '',
        "description" TEXT NOT NULL DEFAULT '',
        "priority" todo_priority NOT NULL DEFAULT 'low',
        "status" todo_status NOT NULL DEFAULT 'pending',
        "started_date" date,
        "due_date" date,
        "completed_at" timestamptz DEFAULT NULL,
        "created_at" timestamptz NOT NULL DEFAULT (now ()),
        "updated_at" timestamptz NOT NULL DEFAULT (now ())
    );

-- TABLE: RECURRENCES
CREATE TABLE
    IF NOT EXISTS "public"."recurrences" (
        "id" UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        "todo_id" UUID NOT NULL REFERENCES public.todos (id) ON DELETE CASCADE,
        -- Đảm bảo 1 todo chỉ có 1 settings lặp lại
        CONSTRAINT uniq_recurrences_todo_id UNIQUE (todo_id),
        "recurrence_pattern" recurrence_pattern DEFAULT 'daily',
        "reminder_at" time,
        "created_at" timestamptz NOT NULL DEFAULT (now ())
    );

-- TABLE: TAGS
CREATE TABLE
    IF NOT EXISTS "public"."tags" (
        "id" UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        "user_id" UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
        "name" VARCHAR(64) NOT NULL DEFAULT '',
        "color" VARCHAR(7) NOT NULL DEFAULT '#000000',
        "created_at" timestamptz NOT NULL DEFAULT now ()
    );

-- TABLE: TODO_TAGS 
CREATE TABLE
    IF NOT EXISTS "public"."todo_tags" (
        "todo_id" UUID NOT NULL REFERENCES public.todos (id) ON DELETE CASCADE,
        "tag_id" UUID NOT NULL REFERENCES public.tags (id) ON DELETE CASCADE,
        PRIMARY KEY ("todo_id", "tag_id")
    );

-- ================================================= 3. INDEXES =================================================
-- TODOS: Index tối ưu cho việc query theo user và các bộ lọc phổ biến
CREATE INDEX IF NOT EXISTS idx_todos_user_id ON public.todos (user_id);

CREATE INDEX IF NOT EXISTS idx_todos_user_status ON public.todos (user_id, status);

CREATE INDEX IF NOT EXISTS idx_todos_user_due_date ON public.todos (user_id, due_date);

-- RECURRENCES
CREATE INDEX IF NOT EXISTS idx_recurrences_todo_id ON public.recurrences (todo_id);

-- TAGS
CREATE INDEX IF NOT EXISTS idx_tags_user_id ON public.tags (user_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_tags_user_name ON public.tags (user_id, name);

-- TODO_TAGS
CREATE INDEX IF NOT EXISTS idx_todo_tags_tag_id ON public.todo_tags (tag_id);

-- ================================================= 4. COMMENTS =================================================
COMMENT ON TABLE public.todos IS 'Bảng chứa dữ liệu công việc chính.';

COMMENT ON TABLE public.recurrences IS 'Lưu cấu hình lặp lại của todo.';

COMMENT ON TABLE public.tags IS 'Nhãn dán cho công việc.';

-- ================================================= 5. RLS (Security) =================================================
-- Bật RLS cho tất cả bảng
ALTER TABLE public.todos ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.recurrences ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.todo_tags ENABLE ROW LEVEL SECURITY;

-- 5.1 POLICY FOR TODOS (QUAN TRỌNG: Dùng FOR ALL thay vì FOR INSERT)
CREATE POLICY "Users can manage their own todos" ON "public"."todos" FOR ALL -- Cho phép: SELECT, INSERT, UPDATE, DELETE
TO authenticated USING (auth.uid () = user_id) -- Điều kiện để được Xem/Sửa/Xóa
WITH
    CHECK (auth.uid () = user_id);

-- Điều kiện để được Insert
-- 5.2 POLICY FOR RECURRENCES (Check quyền qua todo_id)
CREATE POLICY "Policy for recurrences based on todo ownership" ON "public"."recurrences" FOR ALL USING (
    exists (
        select
            1
        from
            public.todos
        where
            todos.id = recurrences.todo_id
            and todos.user_id = auth.uid ()
    )
)
WITH
    CHECK (
        exists (
            select
                1
            from
                public.todos
            where
                todos.id = todo_id
                and todos.user_id = auth.uid ()
        )
    );

-- 5.3 POLICY FOR TAGS (Cơ bản)
CREATE POLICY "Users can manage their own tags" ON "public"."tags" FOR ALL USING (auth.uid () = user_id)
WITH
    CHECK (auth.uid () = user_id);

-- 5.4 POLICY FOR TODO_TAGS (Check quyền qua todo và tag)
CREATE POLICY "Users can manage their todo tags" ON "public"."todo_tags" FOR ALL USING (
    exists (
        select
            1
        from
            public.tags
        where
            tags.id = todo_tags.tag_id
            and tags.user_id = auth.uid ()
    )
);

-- ================================================= 6. TRIGGERS & FUNCTIONS =================================================
-- Extension update thời gian
CREATE EXTENSION IF NOT EXISTS moddatetime SCHEMA extensions;

-- Trigger updated_at cho todos
CREATE TRIGGER handle_updated_at_todos BEFORE
UPDATE ON public.todos FOR EACH ROW EXECUTE PROCEDURE moddatetime (updated_at);

-- Trigger seed data cho tags khi user đăng ký mới
CREATE OR REPLACE FUNCTION public.seed_default_tags()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.tags (user_id, name, color)
        VALUES
        (NEW.id, 'Ưu tiên cao', '#EF4444'),   -- Red
        (NEW.id, 'Công việc', '#3B82F6'),     -- Blue
        (NEW.id, 'Cá nhân', '#10B981'),       -- Emerald
        (NEW.id, 'Học tập', '#F59E0B'),       -- Amber
        (NEW.id, 'Gia đình', '#EC4899'),      -- Pink
        (NEW.id, 'Giải trí', '#8B5CF6'),      -- Violet
        (NEW.id, 'Sức khỏe', '#14B8A6'),      -- Teal
        (NEW.id, 'Tài chính', '#84CC16'),     -- Lime
        (NEW.id, 'Mua sắm', '#F97316'),       -- Orange
        (NEW.id, 'Ý tưởng', '#06B6D4');       -- Cyan
        RETURN NEW;
END;
$$;


-- Chỉ tạo trigger nếu chưa tồn tại (Postgres cũ không hỗ trợ IF NOT EXISTS cho trigger nên drop trước)
DROP TRIGGER IF EXISTS on_auth_user_created_seed_tags ON auth.users;

CREATE TRIGGER on_auth_user_created_seed_tags AFTER INSERT ON auth.users FOR EACH ROW EXECUTE PROCEDURE public.seed_default_tags ();