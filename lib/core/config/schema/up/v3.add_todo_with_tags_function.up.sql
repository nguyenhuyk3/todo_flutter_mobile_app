-- ================================================= FUNCTION: add_todo_with_tags =================================================
-- Thêm todo + recurrences (nếu có) + todo_tags trong một transaction.
-- Gọi từ Flutter qua Supabase RPC.
-- Bảo mật: chỉ cho phép insert với user_id = auth.uid().

CREATE OR REPLACE FUNCTION public.add_todo_with_tags(
  p_user_id uuid,
  p_title text,
  p_description text,
  p_priority public.todo_priority,
  p_status public.todo_status,
  p_started_date date,
  p_due_date date,
  p_recurrence_pattern public.recurrence_pattern DEFAULT 'once',
  p_reminder_at time DEFAULT NULL,
  p_tag_ids uuid[] DEFAULT '{}'
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_todo_id uuid;
  v_todo_row jsonb;
  v_tag_id uuid;
BEGIN
  -- Chỉ cho phép thêm todo cho chính user đang đăng nhập
  IF p_user_id IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'Forbidden: user_id does not match';
  END IF;

  -- 1) Insert todo
  INSERT INTO public.todos (user_id, title, description, priority, status, started_date, due_date)
  VALUES (p_user_id, p_title, p_description, p_priority, p_status, p_started_date, p_due_date)
  RETURNING id INTO v_todo_id;

  -- 2) Recurrence (nếu không phải once)
  IF p_recurrence_pattern IS NOT NULL AND p_recurrence_pattern != 'once' THEN
    INSERT INTO public.recurrences (todo_id, recurrence_pattern, reminder_at)
    VALUES (v_todo_id, p_recurrence_pattern, p_reminder_at);
  END IF;

  -- 3) Todo_tags
  IF p_tag_ids IS NOT NULL AND array_length(p_tag_ids, 1) > 0 THEN
    FOREACH v_tag_id IN ARRAY p_tag_ids
    LOOP
      INSERT INTO public.todo_tags (todo_id, tag_id) VALUES (v_todo_id, v_tag_id);
    END LOOP;
  END IF;

  -- 4) Trả về todo vừa tạo (dạng jsonb cho Flutter parse)
  SELECT to_jsonb(t.*) INTO v_todo_row FROM public.todos t WHERE t.id = v_todo_id;
  RETURN v_todo_row;
END;
$$;

-- Grant execute cho authenticated users
GRANT EXECUTE ON FUNCTION public.add_todo_with_tags(uuid, text, text, public.todo_priority, public.todo_status, date, date, public.recurrence_pattern, time, uuid[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.add_todo_with_tags(uuid, text, text, public.todo_priority, public.todo_status, date, date, public.recurrence_pattern, time, uuid[]) TO service_role;

COMMENT ON FUNCTION public.add_todo_with_tags IS 'Thêm todo + recurrences + todo_tags trong một transaction. Gọi qua RPC từ app.';
