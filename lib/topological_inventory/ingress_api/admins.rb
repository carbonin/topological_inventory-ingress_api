require "json"

module TopologicalInventory
  IngressApi.add_route("POST", "/topological_inventory/ingress_api/0.0.1/inventory", {
    "resourcePath" => "/Admins",
    "summary" => "save inventory",
    "nickname" => "save_inventory", 
    "responseClass" => "void", 
    "endpoint" => "/inventory", 
    "notes" => "Submits a payload to be persisted to the database",
    "parameters" => [
      {
        "name" => "body",
        "description" => "Inventory payload",
        "dataType" => "Inventory",
        "paramType" => "body",
      }
      ]}) do
    cross_origin

    messaging_client.publish_topic(
      :service => "topological_inventory-persister",
      :event   => "inventory",
      :sender  => "topological_inventory-ingress_api",
      :payload => JSON.load(request.body.read),
    )

    {"message" => "yes, it worked"}.to_json
  end
end
