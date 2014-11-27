class Users
  LEGAL_FIELDS = [:pfsNumber, :signatureUrl, :initialsUrl]

  def initialize(aws_connection)
    @table = aws_connection.table('wcpfs-users')
  end

  def ensure(profile)
    profile_id = "google-" + profile["id"]
    email = profile["emails"].find { |e| e["type"] == 'account' }
    user = @table.all.find {|u| u[:id] == profile_id }
    return user if user
    @table.save({
      email: email["value"],
      name: profile["displayName"],
      pic: profile["image"]["url"],
      subscribed: true,
      id: profile_id
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
    unless (new_info.keys.all? {|k| LEGAL_FIELDS.include? k})
      raise "Bad User Field(s) #{new_info.keys.inspect}"
    end

    @table.save(find(id).merge! new_info)
  end
end
