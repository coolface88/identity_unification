defmodule Loyalty.DataModel do
  require Logger
  alias Loyalty.DataAcquisitionGraph, as: DAG
  alias Loyalty.DataLabels, as: Label  

  def get_components() do
    GenServer.call(DAG, [:components])
  end

  def get_vertex_labels(v) do
    GenServer.call(DAG, [:vertex_labels, v])
  end

  def get_vertices() do
    GenServer.call(DAG, [:vertices])
  end

  def get_vertex_properties(v) do
    GenServer.call(DAG, [:look_up, v])  
  end

  def list_all_nodes_labels() do
    list = []
    Enum.map(get_vertices(), fn x -> r = get_vertex_labels(x);
                                     Enum.concat(list, [x,r]) end)
  end

  def get_nodes_by_label(l) do
    all = list_all_nodes_labels()
    Enum.reduce(all, [], fn x, acc -> [a,b] = x
                                      if Enum.member?(b,l) do
                                        Enum.concat(acc, [a])
                                      else
                                        acc
                                      end
                         end)
  end

  def get_properties_by_labels(l) do
    all = list_all_nodes_labels()
    Enum.reduce(all, [], fn x, acc -> [a,b] = x 
                                      p = get_vertex_properties(a)
                                      if Enum.member?(b,l) do
                                        Enum.concat(acc, [p])
                                      else
                                        acc 
                                      end 
                         end) 
  end

  def get_same_hotel_id_nodes() do
    all = get_properties_by_labels(Label.id)
    Enum.reduce(all, %{}, fn x, acc -> [{v,{_,k}}] = x
                                       val = Map.get(acc, k)
                                       if val != nil  do
                                         nv = Enum.concat(val, [v]) 
                                         Map.put(acc, k, nv)
                                       else
                                         Map.put(acc, k, [v])
                                       end
                                       
                         end)
  end

  def get_same_hotel_destination_nodes() do
    all = get_properties_by_labels(Label.destination)
    Enum.reduce(all, %{}, fn x, acc -> [{v,{_,k}}] = x
                                       val = Map.get(acc, k)
                                       if val != nil  do
                                         nv = Enum.concat(val, [v])
                                         Map.put(acc, k, nv)
                                       else
                                         Map.put(acc, k, [v])
                                       end

                         end)
  end

  def get_same_hotel_components_nodes(hotel_id) do
    all = get_same_hotel_id_nodes()
    m = Map.get(all, hotel_id)
    if m != nil do 
      Enum.reduce(m, [], fn x, acc ->  
                    c = get_components()
                    l = Enum.reduce(c, [],  fn t, a -> 
                          if x in t  do
                            Enum.concat(a, t)
                          else
                            a
                          end
                        end)
                    Enum.concat(acc, l)
      end)
    end                 
  end

  def get_same_hotel_components_destination_nodes(destination) do
    all = get_same_hotel_destination_nodes()
    m = if is_integer(destination), do: Map.get(all, destination)
    if m != nil do
      Enum.reduce(m, [], fn x, acc ->
                    c = get_components()
                    l = Enum.reduce(c, [],  fn t, a ->
                          if x in t  do
                            Enum.concat(a, t)
                          else
                            a
                          end
                        end)
                    Enum.concat(acc, l)
      end)
    end
  end

  def get_same_hotel_properties(id) do
    all = get_same_hotel_components_nodes(id)
    Enum.reduce(all, [], fn x, acc ->  l  = get_vertex_properties(x) 
                                      Enum.concat(acc, l)
    end) 
  end

  def get_same_hotel_properties_by_destination(destination) do
    all = get_same_hotel_components_destination_nodes(destination)
    Enum.reduce(all, [], fn x, acc ->  l  = get_vertex_properties(x)
                                      Enum.concat(acc, l)
    end)
  end

  def get_out_neighbors(v) do
    GenServer.call(DAG, [:out_neighbors, v])    
  end
  
  def merge_data(id) do
    {k,v} = id
    components = cond do 
                   k == "hotel_id" -> get_same_hotel_components_nodes(v)
                   k == "hotel_destination"  -> get_same_hotel_components_destination_nodes(v)
                 end
    if components != nil do   
      r = Enum.reduce(components, %{}, fn x, acc -> 
                                             p = get_vertex_properties(x)
                                             l = get_vertex_labels(x)
                                             cond do
                                               Label.id in l -> 
                                                 [{_,{_,v}}] = p
                                                 Map.put_new(acc, "id", v)
                                               Label.destination in l ->
                                                 [{_,{_,v}}] = p
                                                 Map.put_new(acc, "destination_id", v)
                                               Label.hotel_name in l ->
                                                 [{_,{_,v}}] = p
                                                 Map.put_new(acc, "name", "")
                                                 name_tmp = Map.put_new(acc, "name_tmp", [])
                                                 tmp_val = Map.get(name_tmp, "name_tmp")
                                                 tmp_l = cond do
                                                           v != nil -> tmp_val ++ [v]
                                                           true     -> tmp_val
                                                         end 
                                                 unique = Enum.uniq(tmp_l)
                                                 new_name = Enum.reduce(unique, "", fn x, r  ->  x <> " | " <> r end)  
                                                 uniq = Map.put(acc, "name_tmp", unique)
                                                 Map.put(uniq, "name", new_name)
                                               Label.latitude in l ->
                                                 [{_,{_,v}}] = p
                                                 lk = Map.put_new(acc, "location", %{})
                                                 lv = Map.get(lk, "location")
                                                 latk = Map.put_new(lv, "lat", 0)
                                                 latv = Map.get(latk, "lat")
                                                 nv = if latv != v, do: v, else: latv
                                                 nc = Map.put(lv, "lat", nv)
                                                 Map.put(acc, "location", nc)
                                               Label.longitude in l ->
                                                 [{_,{_,v}}] = p
                                                 lk = Map.put_new(acc, "location", %{})
                                                 lv = Map.get(lk, "location")
                                                 lngk = Map.put_new(lv, "lng", 0)
                                                 lngv = Map.get(lngk, "lng")
                                                 nv = if lngv != v, do: v, else: lngv 
                                                 nc = Map.put(lv, "lng", nv)
                                                 Map.put(acc, "location", nc)
                                               Label.address in l ->
                                                 v = case p do
                                                      [{_,{_,val}}] -> val
                                                      [{_,{_,_,val}}] -> val
                                                     end
                                                 lk = Map.put_new(acc, "location", %{})
                                                 lv = Map.get(lk, "location")
                                                 Map.put_new(lv, "address", "")
                                                 address_tmp = Map.put_new(acc, "address_tmp", [])
                                                 tmp_val = Map.get(address_tmp, "address_tmp")
                                                 tmp_l = cond do
                                                           v != nil -> tmp_val ++ [v]
                                                           true     -> tmp_val
                                                         end
                                                 unique = Enum.uniq(tmp_l)
                                                 new_address = Enum.reduce(unique, "", fn x, r  ->  x <> " | " <> r end)
                                                 nc = Map.put(lv, "address", new_address)
                                                 loc = Map.put(acc, "location", nc)
                                                 Map.put(loc, "address_tmp", unique) 
                                               Label.city in l ->
                                                 [{_,{_,v}}] = p
                                                 lk = Map.put_new(acc, "location", %{})
                                                 lv = Map.get(lk, "location")
                                                 Map.put_new(lv, "city", "")
                                                 city_tmp = Map.put_new(acc, "city_tmp", [])
                                                 tmp_val = Map.get(city_tmp, "city_tmp")
                                                 tmp_l = cond do
                                                           v != nil -> tmp_val ++ [v]
                                                           true     -> tmp_val
                                                         end
                                                 unique = Enum.uniq(tmp_l)
                                                 new_city = Enum.reduce(unique, "", fn x, r  ->  x <> " | " <> r end)
                                                 nc = Map.put(lv, "city", new_city)
                                                 loc = Map.put(acc, "location", nc)
                                                 Map.put(loc, "city_tmp", unique)
                                               Label.country in l ->
                                                 v = case p do
                                                      [{_,{_,val}}] -> val
                                                      [{_,{_,_,val}}] -> val
                                                     end
                                                 lk = Map.put_new(acc, "location", %{})
                                                 lv = Map.get(lk, "location")
                                                 Map.put_new(lv, "country", "")                     
                                                 country_tmp = Map.put_new(acc, "country_tmp", [])
                                                 tmp_val = Map.get(country_tmp, "country_tmp")
                                                 tmp_l = cond do
                                                           v != nil -> tmp_val ++ [v]
                                                           true     -> tmp_val
                                                         end
                                                 unique = Enum.uniq(tmp_l)
                                                 new_country = Enum.reduce(unique, "", fn x, r  ->  x <> " | " <> r end)
                                                 nc = Map.put(lv, "country", new_country)
                                                 loc = Map.put(acc, "location", nc)
                                                 Map.put(loc, "country_tmp", unique)
                                               Label.description in l ->
                                                 [{_,{_,v}}] = p
                                                 Map.put_new(acc, "description", "")
                                                 description_tmp = Map.put_new(acc, "description_tmp", [])
                                                 tmp_val = Map.get(description_tmp, "description_tmp")
                                                 tmp_l = cond do 
                                                           v != nil -> tmp_val ++ [v]
                                                           true     -> tmp_val 
                                                         end
                                                 unique = Enum.uniq(tmp_l)
                                                 new_description = Enum.reduce(unique, "", fn x, r  ->  x <> " | " <> r end)
                                                 t = Map.put(acc, "description", new_description)
                                                 Map.put(t, "description_tmp", unique)
                                               Label.postal_code in l ->
                                                 [{_,{_,v}}] = p
                                                 Map.put_new(acc, "postal_code", "")
                                                 pc_tmp = Map.put_new(acc, "pc_tmp", [])
                                                 tmp_val = Map.get(pc_tmp, "pc_tmp")
                                                 tmp_l = cond do
                                                           v != nil -> tmp_val ++ [v]
                                                           true     -> tmp_val
                                                         end
                                                 unique = Enum.uniq(tmp_l)
                                                 new_pc = Enum.reduce(unique, "", fn x, r  ->  x <> " | " <> r end)
                                                 uniq = Map.put(acc, "pc_tmp", unique)
                                                 Map.put(uniq, "postal_code", new_pc)
                                               Label.booking_conditions in l ->
                                                 [{_,{_,v}}] = p
                                                 bk = Map.put_new(acc, "booking_conditions", [])
                                                 bv = Map.get(bk, "booking_conditions")
                                                 nv = Enum.concat(bv, v)
                                                 unique = Enum.uniq(nv)
                                                 Map.put(acc, "booking_conditions", unique)
                                               Label.amenities_general in l ->
                                                 v = case p do
                                                      [{_,{_,val}}] -> val
                                                      [{_,{_,_,val}}] -> val
                                                     end
                                                 ak = Map.put_new(acc, "amenities", %{})
                                                 av = Map.get(ak, "amenities")
                                                 gk = Map.put_new(av, "general", [])
                                                 gv = Map.get(gk, "general")
                                                 nv = cond do
                                                        v != nil -> Enum.concat(gv, v)
                                                        true     -> gv
                                                      end
                                                 unique = Enum.uniq(nv)
                                                 ng = Map.put(gk, "general", unique)
                                                 Map.put(acc, "amenities", ng) 
                                               Label.amenities_room in l ->
                                                 v = case p do
                                                      [{_,{_,val}}] -> val
                                                      [{_,{_,_,val}}] -> val
                                                     end
                                                 ak = Map.put_new(acc, "amenities", %{})
                                                 av = Map.get(ak, "amenities")
                                                 rk = Map.put_new(av, "room", [])
                                                 rv = Map.get(rk, "room")
                                                 nv = cond do
                                                        v != nil -> Enum.concat(rv, v)
                                                        true     -> rv
                                                      end
                                                 unique = Enum.uniq(nv)
                                                 nr = Map.put(rk, "room", unique)
                                                 Map.put(acc, "amenities", nr)
                                               Label.images_rooms_link in l ->
                                                 [{link_v,{_,_,_,v}}] = p
                                                 m = Map.put_new(acc, "images", %{})
                                                 im = Map.get(m, "images")
                                                 imrooms = Map.put_new(im, "rooms", [])
                                                 rl = Map.get(imrooms, "rooms")
                                                 link = Map.put_new(%{}, "link", v)
                                                 [nei] = get_out_neighbors(link_v)
                                                 [{_,{_,_,_,c}}] = get_vertex_properties(nei)
                                                 lcaption = Map.put_new(link, "description", c)
                                                 ll = rl ++ [lcaption]
                                                 nr = Map.put(imrooms, "rooms", ll)
                                                 Map.put(acc, "images", nr)
                                               Label.images_amenities_link in l ->
                                                 [{link_v,{_,_,_,v}}] = p
                                                 m = Map.put_new(acc, "images", %{})
                                                 im = Map.get(m, "images")
                                                 imamenities = Map.put_new(im, "amenities", [])
                                                 rl = Map.get(imamenities, "amenities")
                                                 link = Map.put_new(%{}, "link", v)
                                                 [nei] = get_out_neighbors(link_v)
                                                 [{_,{_,_,_,c}}] = get_vertex_properties(nei)
                                                 lcaption = Map.put_new(link, "description", c)
                                                 ll = rl ++ [lcaption]
                                                 nr = Map.put(imamenities, "amenities", ll)
                                                 Map.put(acc, "images", nr)
                                               Label.images_rooms_caption in l ->
                                                 acc
                                               Label.images_amenities_caption in l ->
                                                 acc 
                                               true -> 
                                                 [{_,v}] = p
                                                 Map.put_new(acc, "unknown_data", v)
                                             end
       end)
    {_,r1} = Map.pop(r, "name_tmp")
    {_,r2} = Map.pop(r1, "pc_tmp")
    {_,r3} = Map.pop(r2, "address_tmp")
    {_,r4} = Map.pop(r3, "city_tmp")
    {_,r5} = Map.pop(r4, "name_tmp")
    {_,r6} = Map.pop(r5, "country_tmp")
    {_,r7} = Map.pop(r6, "description_tmp")
    r7
    end
  end

end
