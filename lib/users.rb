class Users

  def initialize(aws_connection)
    @table = aws_connection.table('wcpfs-users')
  end

  def ensure(profile)
    email = profile["emails"].find { |e| e["type"] == 'account' }
    user = @table.all.find {|u| u["email"] == email }
    return user if user
    @table.save({
      email: email["value"],
      name: profile["displayName"],
      pic: profile["image"]["url"],
      subscribed: true,
      id: "google-" + profile["id"]
    })
  end

  def subscribe(id) 
    user = find(id)
    user[:subscribed] = true
    @table.save(user)
  end

  def subscriptions
    @table.all.select {|u| u[:subscribed]}
  end

  def find(id)
    @table.all.find {|u| u[:id] == id}
  end

  def update(id, new_info)
    @table.save(find(id).merge! new_info)
  end
end
