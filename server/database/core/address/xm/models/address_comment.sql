﻿select private.create_model(

-- Model name, schema, table

'address_comment', 'xm', 'comment',

-- Columns

E'{
  "comment.guid as guid",
  "comment.source_id as address",
  "comment.date as date",
  "comment.username as username",
  "comment.comment_type as comment_type",
  "comment.text as text",
  "comment.is_public as is_public",
  "comment.can_update as can_update"}',
     
-- Rules

E'{"

-- insert rule

create or replace rule \\"_CREATE\\" as on insert to xm.address_comment 
  do instead

insert into xm.comment (
  guid,
  source_id,
  source,
  date,
  username,
  comment_type,
  text,
  is_public  )
values (
  new.guid,
  new.address,
  \'ADDR\',
  new.date,
  new.username,
  new.comment_type,
  new.text,
  new.is_public );

","

-- update rule

create or replace rule \\"_UPDATE\\" as on update to xm.address_comment 
  do instead

update xm.comment set
  text = new.text,
  is_public = new.is_public
where ( guid = old.guid );

","

-- delete rule

create or replace rule \\"_DELETE\\" as on delete to xm.address_comment 
  do instead nothing;

"}', 

-- Conditions, Comment, System

E'{"comment.source = \'ADDR\'"}', 'Address Comment Model', true, true);
