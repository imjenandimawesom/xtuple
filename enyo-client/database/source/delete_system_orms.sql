DO $$

  plv8.execute("select xt.js_init()");
  plv8.execute("delete from xt.orm where orm_json ~ '\"isSystem\":true';");

$$ language plv8;
