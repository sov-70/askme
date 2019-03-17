module ApplicationHelper
  def user_avatar(user)
    if user.avatar_url.present?
      user.avatar_url   
    else
      asset_path "avatar.jpg"  
    end  
  end

  def sklonjator(val, vopros, voprosa, voprosov)
     val_10 = val%10
     if val.between?(11,19) 
       res = voprosov
     elsif val_10 == 1
       res = vopros
     elsif val_10.between?(2,4)
       res = voprosa
     else
       res = voprosov
     end
     val.to_s + " "+ res
  end

end
