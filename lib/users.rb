require 'aws_entity'

class Users
  include AWSEntity

  def ensure(profile)
    email = profile["emails"].find { |e| e["type"] == 'account' }
    user = all.find {|u| u["email"] == email }
    return user if user
    save({
      "email" => email["value"],
      "name" => profile["displayName"],
      "pic" => profile["image"]["url"],
      "id" => "google-" + profile["id"]
    })
  end

  def subscribe(email)
    user = all.find {|u| u["email"] == email}
    user["subscribed"] = true
    save(user)
  end

  def subscriptions
    all.select {|u| u["subscribed"]}
  end
end
