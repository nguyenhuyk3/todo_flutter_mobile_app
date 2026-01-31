-- ================================================= 1. ENUMS & TYPES =================================================
CREATE TYPE public.todo_priority AS ENUM ('undefined', 'low', 'medium', 'high', 'urgent');

CREATE TYPE public.todo_status AS ENUM (
    'pending',
    'in_progress',
    'completed',
    'cancelled'
);

CREATE TYPE public.recurrence_pattern AS ENUM ('once', 'daily', 'weekday', 'custom');

-- ================================================= 2. TABLES =================================================
-- TABLE: PROJECTS
CREATE TABLE
    "public"."projects" (
        "id" UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        "user_id" UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
        "name" VARCHAR(256) NOT NULL DEFAULT '',
        "description" TEXT NOT NULL DEFAULT '',
        "color" VARCHAR(7) NOT NULL DEFAULT '#000000', -- Hex color chuẩn 7 ký tự
        "is_archived" BOOLEAN NOT NULL DEFAULT FALSE,
        "created_at" timestamptz NOT NULL DEFAULT (now ()),
        "updated_at" timestamptz NOT NULL DEFAULT (now ())
    );

-- TABLE: TODOS
CREATE TABLE
    "public"."todos" (
        "id" UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        "user_id" UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
        "project_id" UUID REFERENCES public.projects (id) ON DELETE SET NULL,
        "title" VARCHAR(256) NOT NULL DEFAULT '',
        "description" TEXT NOT NULL DEFAULT '',
        "priority" todo_priority NOT NULL DEFAULT 'low',
        "status" todo_status NOT NULL DEFAULT 'pending',
        -- Các trường thời gian thực tế của công việc
        "started_date" date,
        "due_date" date,
        "completed_at" timestamptz DEFAULT NULL,
        -- Cấu trúc
        "parent_todo_id" UUID REFERENCES public.todos (id) ON DELETE CASCADE,
        "position" INTEGER NOT NULL DEFAULT 1, -- Thứ tự sắp xếp
        "created_at" timestamptz NOT NULL DEFAULT (now ()),
        "updated_at" timestamptz NOT NULL DEFAULT (now ())
    );

-- TABLE: RECURRENCES
CREATE TABLE
    "public"."recurrences" (
        "id" UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        "todo_id" UUID NOT NULL REFERENCES public.todos (id) ON DELETE CASCADE,
        -- Đảm bảo 1 todo chỉ có 1 settings lặp lại
        CONSTRAINT uniq_recurrences_todo_id UNIQUE (todo_id),
        "recurrence_pattern" recurrence_pattern DEFAULT 'daily',
        -- -- Cấu hình lặp lại có thể cần thời gian riêng biệt với todo gốc
        -- "started_date" timestamptz NOT NULL DEFAULT (now ()),
        -- "due_date" timestamptz, -- NULL nghĩa là lặp vô tận
        -- Nếu cần nhắc nhở lặp lại theo quy luật khác với task gốc
        "reminder_at" time,
        "created_at" timestamptz NOT NULL DEFAULT (now ())
    );

-- TABLE: TAGS
CREATE TABLE
    "public"."tags" (
        "id" UUID PRIMARY KEY DEFAULT gen_random_uuid (),
        "user_id" UUID NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
        "name" VARCHAR(64) NOT NULL DEFAULT '',
        "color" VARCHAR(7) NOT NULL DEFAULT '#000000',
        "created_at" timestamptz NOT NULL DEFAULT now ()
    );

-- TABLE: TODO_TAGS (Bảng trung gian)
CREATE TABLE
    "public"."todo_tags" (
        "todo_id" UUID NOT NULL REFERENCES public.todos (id) ON DELETE CASCADE,
        "tag_id" UUID NOT NULL REFERENCES public.tags (id) ON DELETE CASCADE,
        PRIMARY KEY ("todo_id", "tag_id")
    );

-- ================================================= 3. INDEXES =================================================
-- PROJECTS
CREATE INDEX IF NOT EXISTS idx_projects_user_id ON public.projects (user_id);

CREATE INDEX IF NOT EXISTS idx_projects_active ON public.projects (user_id)
WHERE
    is_archived = FALSE;

-- TODOS
CREATE INDEX IF NOT EXISTS idx_todos_user_id ON public.todos (user_id);

CREATE INDEX IF NOT EXISTS idx_todos_project_id ON public.todos (project_id);

CREATE INDEX IF NOT EXISTS idx_todos_parent_id ON public.todos (parent_todo_id);

CREATE INDEX IF NOT EXISTS idx_todos_user_status ON public.todos (user_id, status);

CREATE INDEX IF NOT EXISTS idx_todos_user_due_date ON public.todos (user_id, due_date);

CREATE INDEX IF NOT EXISTS idx_todos_project_position ON public.todos (project_id, position);

-- RECURRENCES
CREATE INDEX IF NOT EXISTS idx_recurrences_todo_id ON public.recurrences (todo_id);

-- TAGS
CREATE INDEX IF NOT EXISTS idx_tags_user_id ON public.tags (user_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_tags_user_name ON public.tags (user_id, name);

-- TODO_TAGS
CREATE INDEX IF NOT EXISTS idx_todo_tags_tag_id ON public.todo_tags (tag_id);

-- ================================================= 4. COMMENTS =================================================
-- PROJECTS
COMMENT ON TABLE public.projects IS 'Quản lý các dự án hoặc nhóm công việc lớn.';

COMMENT ON COLUMN public.projects.is_archived IS 'Đánh dấu dự án đã hoàn thành, ẩn khỏi danh sách chính.';

-- TODOS
COMMENT ON TABLE public.todos IS 'Bảng chứa dữ liệu công việc chính.';

COMMENT ON COLUMN public.todos.project_id IS 'FK nối tới Projects. NULL là công việc Inbox.';

COMMENT ON COLUMN public.todos.parent_todo_id IS 'Hỗ trợ Subtask.';

COMMENT ON COLUMN public.todos.position IS 'Số thứ tự sắp xếp (Kanban/List).';

-- RECURRENCES
COMMENT ON TABLE public.recurrences IS 'Lưu cấu hình lặp lại. Tách khỏi Todos để giảm tải bảng chính.';

-- COMMENT ON COLUMN public.recurrences.end_date IS 'Ngày kết thúc chuỗi lặp (NULL = vô tận).';

-- TAGS
COMMENT ON TABLE public.tags IS 'Nhãn dán cross-project.';

-- ================================================= 5. RLS (Security) =================================================
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.todos ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.recurrences ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.todo_tags ENABLE ROW LEVEL SECURITY;

-- Tạo Policy cho phép INSERT
-- Luật: User chỉ được Insert dòng mới nếu cột user_id của dòng đó BẰNG VỚI id của user đang đăng nhập
CREATE POLICY "Users can insert their own todos"
ON "public"."todos"
FOR INSERT
TO authenticated -- Chỉ user đã đăng nhập mới được làm
WITH CHECK (auth.uid() = user_id);

-- Tạo Policy kiểm tra quyền sở hữu thông qua bảng cha (todos)
CREATE POLICY "Policy for recurrences based on todo ownership"
ON "public"."recurrences"
FOR ALL
USING (
    -- Kiểm tra cho lệnh SELECT/UPDATE/DELETE:
    -- Tìm xem cái todo_id của dòng này thuộc user nào
    exists (
        select 1 from public.todos
        where todos.id = recurrences.todo_id
        and todos.user_id = auth.uid()
    )
)
WITH CHECK (
    -- Kiểm tra cho lệnh INSERT:
    -- Dữ liệu sắp được thêm vào phải trỏ tới 1 todo của chính mình
    exists (
        select 1 from public.todos
        where todos.id = todo_id
        and todos.user_id = auth.uid()
    )
);
-- ================================================= 6. TRIGGERS & FUNCTIONS =================================================
-- Auto-update `updated_at`
CREATE EXTENSION IF NOT EXISTS moddatetime SCHEMA extensions;

CREATE TRIGGER handle_updated_at_projects BEFORE
UPDATE ON public.projects FOR EACH ROW EXECUTE PROCEDURE moddatetime (updated_at);

CREATE TRIGGER handle_updated_at_todos BEFORE
UPDATE ON public.todos FOR EACH ROW EXECUTE PROCEDURE moddatetime (updated_at);

-- SEED DEFAULT TAGS
CREATE OR REPLACE FUNCTION public.seed_default_tags()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.tags (user_id, name, color)
        VALUES
            (NEW.id, 'Chưa đặt tên', '#EF4444'),
            (NEW.id, 'Chưa đặt tên', '#3B82F6'),
            (NEW.id, 'Chưa đặt tên', '#10B981'),
            (NEW.id, 'Chưa đặt tên', '#F59E0B'),
            (NEW.id, 'Chưa đặt tên', '#EC4899'),
            (NEW.id, 'Chưa đặt tên', '#8B5CF6'),
            (NEW.id, 'Chưa đặt tên', '#14B8A6'),
            (NEW.id, 'Chưa đặt tên', '#84CC16'),
            (NEW.id, 'Chưa đặt tên', '#F97316'),
            (NEW.id, 'Chưa đặt tên', '#06B6D4');
        RETURN NEW;
END;
$$;

-- Trigger tạo Tags khi user mới đăng ký
CREATE TRIGGER on_auth_user_created_seed_tags AFTER INSERT ON auth.users FOR EACH ROW EXECUTE PROCEDURE public.seed_default_tags ();