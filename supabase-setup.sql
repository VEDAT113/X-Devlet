-- Supabase > SQL Editor'de bir kez çalıştır.

-- 1) Profil fotoğrafları için herkese açık okunabilir bucket
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

create policy "avatars okuma" on storage.objects
  for select using (bucket_id = 'avatars');

create policy "avatars kendi klasorune yukleme" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "avatars kendi dosyasini guncelleme" on storage.objects
  for update to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "avatars kendi dosyasini silme" on storage.objects
  for delete to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

-- 2) "Hesabı sil" butonu için
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from auth.users where id = auth.uid();
end;
$$;

revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
