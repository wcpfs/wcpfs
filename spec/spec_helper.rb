
def fake_new_game
  fake_new_game_no_notes.merge(notes: "My Notes")
end

def fake_new_game_no_notes
  {
    gm_name: "Ben Rady", 
    gm_id: "google-113769764833315172586",
    gm_pic: fake_user_info[:pic],
    datetime: 123456789000, 
    title: "Title", 
  }
end

def fake_user_info
  {
    email: 'benrady@gmail.com',
    name: "Ben Rady",
    pic: "https://lh5.googleusercontent.com/-Pv6s3xoudeE/AAAAAAAAAAI/AAAAAAAAAAA/wa9VTBF_kws/photo.jpg?sz=50",
    id: "google-113769764833315172586"
  }
end

def fake_user_info_2
  {
    email: 'rene@rene.com',
    name: "Rene Duquesnoy",
    pic: "https://lh5.googleusercontent.com/-Pv6s3xoudeE/AAAAAAAAAAI/AAAAAAAAAAA/wa9VTBF_kws/photo.jpg?sz=50",
    id: "google-113769764833315172587"
  }
end

def fake_saved_game
  {
    gameId: 'abc123', 
    seats: [],
    gm_name: "Ben Rady",
    gm_pic: "https://lh5.googleusercontent.com/-Pv6s3xoudeE/AAAAAAAAAAI/AAAAAAAAAAA/wa9VTBF_kws/photo.jpg?sz=50",
    gm_id: 123456,
    datetime: 123456789000,
    title: "City of Golden Death!",
    notes: "Notes notes notes!"
  }
end