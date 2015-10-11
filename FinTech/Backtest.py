from datetime import datetime
import numpy as np
import pytz

def initialize(context):
    
    offset = -2
    
    tz = pytz.timezone('US/Eastern')
    
    context.alpha_articles = [
        ['AET', sid(168), datetime(2014,10,4+offset,5,0,tzinfo=tz), False],
        ['UNH', sid(7792), datetime(2014,10,4+offset,5,0,tzinfo=tz), False],
        ['HQY', sid(47397), datetime(2014,10,4+offset,5,0,tzinfo=tz), False],
        ['FST', sid(2935), datetime(2014,10,4+offset,5,0,tzinfo=tz), False],
        ['AYR', sid(32475), datetime(2014,10,4+offset,5,0,tzinfo=tz), False],
        ['PEIX', sid(27129), datetime(2014,10,3+offset,5,0,tzinfo=tz), False],
        ['AZN', sid(19954), datetime(2014,10,3+offset,5,0,tzinfo=tz), False],
        ['GSK', sid(3242), datetime(2014,10,3+offset,5,0,tzinfo=tz), False],
        ['CSS', sid(1926), datetime(2014,9,30+offset,5,0,tzinfo=tz), False],
        ['XWES', sid(34220), datetime(2014,9,30+offset,5,0,tzinfo=tz), False],
        ['PDCE', sid(5907), datetime(2014,9,30+offset,5,0,tzinfo=tz), False],
        ['SYRG', sid(35051), datetime(2014,9,30+offset,5,0,tzinfo=tz), False],
        ['TECU', sid(7376), datetime(2014,9,30+offset,5,0,tzinfo=tz), False],
        ['MPET', sid(4982), datetime(2014,9,26+offset,5,0,tzinfo=tz), False],
        ['ABTL', sid(19852), datetime(2014,9,26+offset,5,0,tzinfo=tz), False],
        
        ['CAB', sid(26412), datetime(2014,9,26+offset,5,0,tzinfo=tz), False],
        
        ['DKS', sid(24070), datetime(2014,9,26+offset,5,0,tzinfo=tz), False],
        
        ['RGR', sid(6458), datetime(2014,9,26+offset,5,0,tzinfo=tz), False],
        
        ['CARB', sid(41820), datetime(2014,9,24+offset,5,0,tzinfo=tz), False],
        
        ['BAGL', sid(30380), datetime(2014,9,24+offset,5,0,tzinfo=tz), False],
        
        ['UIS', sid(7761), datetime(2014,9,24+offset,5,0,tzinfo=tz), False],
    ]
        
    context.purchase_time = {}
    context.max_holding_days = 5
    
def my_order(security, amount, context, data):
    order(security, amount)
    log.info('Ordered %d of %s at %s.' %
             (amount, security, data[security].datetime))
    log.debug('Current price is %.2f, cash position is %.2f.' %
             (data[security].price, context.portfolio.cash))

def handle_data(context, data):
    # check current holdings
    for sid_ in context.purchase_time.keys():
        if sid_ in data:
            if (data[sid_].datetime - context.purchase_time[sid_]).days >= context.max_holding_days:
                my_order(sid_, -(context.portfolio.positions[sid_].amount), context, data)
                del context.purchase_time[sid_]
    
    # see if we can open a new position
    for i, row in enumerate(context.alpha_articles):
        sid_ = row[1]
        time_ = row[2]
        if not row[3] and sid_ in data and data[sid_].datetime > time_:
            # open a new position
            row[3] = True
            price = data[sid_].price
            amount = round(10000/price)
            my_order(sid_, amount, context, data)
            context.purchase_time[sid_] = data[sid_].datetime