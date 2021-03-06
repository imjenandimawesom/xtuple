select xt.install_js('XM','Customer','xtuple', $$
/* Copyright (c) 1999-2011 by OpenMFG LLC, d/b/a xTuple. 
   See www.xtuple.com/CPAL for the full text of the software license. */

  XM.Customer = {};

  XM.Customer.isDispatchable = true;

  /**
    Determin whether a customer can purchase a given item

    @param {Number} Customer id
    @param {Number} Item id
    @param {Date} Schedule date
    @param {Number} Shipto id
    @returns {Boolean}
  */
  XM.Customer.canPurchase = function (customerId, itemId, scheduleDate, shiptoId) {
    var sql = 'select customerCanPurchase($1, $2, $3, $4::date) as canpurchase;';
    return plv8.execute(sql, [itemId, customerId, shiptoId, scheduleDate])[0].canpurchase;
  };
  
  /**
   Returns an object with a price and type for a given customer, item and quantity.

   @param {Number} customer id
   @param {Number} item id
   @param {Number} quantity
   @param {Object} options:  asOf, shiptoId, quantityUnitId, priceUnitId, currencyId, effective
   @returns Object 
  */
  XM.Customer.itemPrice = function(customerId, itemId, quantity, options) {
    options = options || {};
    var today = new Date(),
      shiptoId = options.shiptoId || -1,
      quantityUnitId,
      priceUnitId,
      currencyId,
      effective,
      asOf,
      result,
      err;

    if (!itemId) {
      err = "Item";
    } else if (!customerId) {
      err = "Customer";
    } else if (!quantity) {
      err = "Quantity" 
    };
    if(err) { plv8.elog(ERROR, err + " is required.") }

    quantityUnitId = options.quantityUnitId || plv8.execute("select item_inv_uom_id as result from item where item_id = $1;", [itemId])[0].result,
    priceUnitId = options.priceUnitId || plv8.execute("select item_price_uom_id as result from item where item_id = $1;", [itemId])[0].result,
    currencyId = options.currencyId || plv8.execute("select basecurrid() as result")[0].result,
    effective = options.effective ? new Date(options.effective) : today,
    asOf = options.asOf ? new Date(options.asOf) : today,
    result = plv8.execute("select itemipsprice($1, $2, $3, $4, $5, $6, $7, $8::date, $9::date, null) as result;", [itemId, customerId, shiptoId, quantity, quantityUnitId, priceUnitId, currencyId, effective, asOf])[0].result;

    result = { price: result.itemprice_price, type: result.itemprice_type };
    return JSON.stringify(result); 
  }

  /**
   Returns a price for a given customer, item, characteristic and quantity.

   @param {Number} customer id
   @param {Number} item id
   @param {Number} characteristic id
   @param {Number} characteristic value
   @param {Number} quantity
   @param {Object} options:  asOf, shiptoId, currencyId, effective
   @returns Object 
  */
  XM.Customer.characteristicPrice = function(customerId, itemId, characteristicId, value, quantity, options) {
    options = options || {};
    var today = new Date(),
      shiptoId = options.shiptoId || -1,
      currencyId,
      effective,
      asOf,
      result,
      err;

    if (!itemId) {
      err = "Item";
    } else if (!customerId) {
      err = "Characteristic";
    } else if (!customerId) {
      err = "Customer";
    } else if (!quantity) {
      err = "Quantity" 
    };
    if(err) { plv8.elog(ERROR, err + " is required.") }

    currencyId = options.currencyId || plv8.execute("select basecurrid() as result")[0].result,
    effective = options.effective ? new Date(options.effective) : today,
    asOf = options.asOf ? new Date(options.asOf) : today,
    result = plv8.execute("select itemcharprice($1, $2, $3, $4, $5, $6, $7, $8::date, $9::date) as result;", [itemId, characteristicId, value, customerId, shiptoId, quantity, currencyId, effective, asOf])[0].result;

    return result; 
  }
  
$$ );
