-- Rollback: xóa function add_todo_with_tags
DROP FUNCTION IF EXISTS public.add_todo_with_tags(uuid, text, text, public.todo_priority, public.todo_status, date, date, public.recurrence_pattern, time, uuid[]);
