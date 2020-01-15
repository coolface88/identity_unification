# Loyalty

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

1 - Project Overview
    This project is to demonstrate a solution for same identity data merging. I decided to use LPG graph to represent 
    the same data semantic relationship where labels are categories. Those categories might be changed in the future. 
    The uncertainty will be modeled by list data structure. The merging operations are basically the functors over the categories.
    Elixir has some buit-in those which I have utilised them alot for the data transformation like Enum.map/reduce.     
    
    Some technologies utilised: Jason, ETS, Supervisor, faultolerance lib (ExternalSrvice)

2 - Data Acquisition

http://0.0.0.0:4000/DataAcquisition?url=https://api.myjson.com/bins/j6kzm
http://0.0.0.0:4000/DataAcquisition?url=https://api.myjson.com/bins/1fva3m
http://0.0.0.0:4000/DataAcquisition?url=https://api.myjson.com/bins/gdmqa

3 - Data Deliver

http://0.0.0.0:4000/DataDeliver/hotel/ids/?ids=["f8c9","iJhz"]
http://0.0.0.0:4000/DataDeliver/hotel/destination?destination=5432

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
