
def fake_new_game
  fake_new_game_no_notes.merge(notes: "My Notes")
end

def fake_new_game_no_notes
  {
    gm_name: "Ben Rady", 
    gm_id: "google-113769764833315172586",
    gm_pic: fake_user_info[:pic],
    gm_email: fake_user_info[:email],
    datetime: 1234567890000,
    title: "City of Golden Death!",
    private: false
  }
end

def fake_user_info
  {
    email: 'benrady@gmail.com',
    name: "Ben Rady",
    subscribed: true,
    pic: "https://lh5.googleusercontent.com/-Pv6s3xoudeE/AAAAAAAAAAI/AAAAAAAAAAA/wa9VTBF_kws/photo.jpg?sz=50",
    id: "google-113769764833315172586"
  }
end

def fake_user_info_2
  {
    email: 'rene@rene.com',
    name: "Rene Duquesnoy",
    subscribed: true,
    pic: "https://lh5.googleusercontent.com/-Pv6s3xoudeE/AAAAAAAAAAI/AAAAAAAAAAA/wa9VTBF_kws/photo.jpg?sz=50",
    id: "google-113769764833315172587"
  }
end

def fake_saved_game_with_discussion
  fake_saved_game.merge({
    discussion: """Part of the discussion.
    > A quote from previous
    > conversations"""
  })
end

def fake_saved_game
  fake_new_game.merge({
    id: 'abc123', 
    seats: [],
    notes: "My Notes"
  })
end
