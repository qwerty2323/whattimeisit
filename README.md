# Time

Возвращает пока только UTC

# Likes

Есть таблица likes (user_id: integer, post_id: integer, created_at: datetime, updated_at: datetime) В этой таблице порядка нескольких миллионов записей. Сервер делает несколько разных запросов по этой таблице, время выполнения этих запросов > 1 sec. Запросы:

```sql

SELECT COUNT(*) FROM likes WHERE user_id = ?
SELECT COUNT(*) FROM likes WHERE post_id = ?
SELECT * FROM likes WHERE user_id = ? AND post_id = ?

```
Проанализировать, значения каких столбцов нам реально нужны:

```sql

SELECT COUNT(post_id) FROM likes WHERE user_id = ?
SELECT COUNT(user_id) FROM likes WHERE post_id = ?
SELECT post_id, user_id FROM likes WHERE user_id = ? AND post_id = ?
```
Если требуется только проверить наличие то, вместо COUNT можно использовать EXIST
```sql
SELECT EXIST(*) FROM likes WHERE user_id = ?
SELECT EXIST(*) FROM likes WHERE post_id = ?
SELECT * FROM likes WHERE user_id = ? AND post_id = ?
```

Как узнать почему тормозят запросы:

```sql
EXPLAIN SELECT COUNT(*) FROM likes WHERE user_id = ?
EXPLAIN SELECT COUNT(*) FROM likes WHERE post_id = ?
EXPLAIN SELECT * FROM likes WHERE user_id = ? AND post_id = ?

```
# Pending Posts

Есть такой запрос:

```sql
  SELECT * FROM pending_posts 
    WHERE user_id < ?
    UNION ALL
  SELECT * FROM pending_posts
    WHERE user_id ?
      AND NOT approved
      AND NOT banned
      AND pending_posts.id NOT IN(
        SELECT pending_post_id FROM viewed_posts
          WHERE user_id = ?)
```
*Нужно создать составной кластерный индекс по столбцам approved и banned, чтобы ускорить поиск в таблице. Не использовать негативные запросы*

Какие индексы надо создать и как изменить запрос (если требуется) чтобы запрос работал максимально быстро.
```sql
  CREATE INDEX PIndex ON pending_posts (approved, banned)

  SELECT * FROM pending_posts 
    WHERE user_id < ?
    UNION ALL
  SELECT * FROM pending_posts WITH(INDEX(PIndex))
    WHERE user_id ?
    AND NOT approvesd
    AND NOT banned
    AND pending_posts.id IN(
      SELECT pending_post_id FROM viewed_posts
        WHERE user_id > ?
        AND WHERE user_id < ?)
```


В качестве базы данных можно использовать любую реляционную (postgres, mysql, oracle и т.д.)