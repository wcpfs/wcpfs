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
      id: "google-" + profile["id"]
    })
  end

  def subscribe(email)
    user = @table.all.find {|u| u[:email] == email}
    user[:subscribed] = true
    save(user)
  end

  def subscriptions
    @table.all.select {|u| u[:subscribed]}
  end
end
