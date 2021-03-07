require 'mechanize'
require 'nokogiri'
require 'dotenv'

Dotenv.load


# コード取得
# xpath
# //*[@id="nav"]/div[4]/div[1]/div[3]/a/text()

# 正規表現  割引コード：MAR35で35%オフ
# 割引コード：のすぐ後ろに


agent = Mechanize.new
agent.user_agent_alias = 'Mac Safari'
# ログイン
agent.get('https://www.myprotein.jp/accountHome.account') do |page|
    response = page.form_with(:action => 'https://www.myprotein.jp/elysiumAuthentication.login') do |form|
        form.field_with(id: 'username').value = ENV["MYPROTEIN_USER"]
        form.field_with(id: 'password').value = ENV["MYPROTEIN_PW"]
    end.submit
end

# コード反映後の値段
page = agent.get('https://www.myprotein.jp/my.basket') #=> Mechanize::Page
form = page.form_with!(id: "discount-form") #=> Mechanize::Page
form.field_with(id: 'discountcode').value = 'LINE'
discounted_page = agent.submit(form)
puts discounted_page.search('//*[@id="mainContent"]/div[2]/div[3]/div/div[1]/div/div[1]/div[2]').inner_text
