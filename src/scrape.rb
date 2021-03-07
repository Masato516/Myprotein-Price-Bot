require 'mechanize'
require 'nokogiri'
require 'dotenv'

Dotenv.load

agent = Mechanize.new
agent.user_agent_alias = 'Mac Safari'

# ログイン
agent.get('https://www.myprotein.jp/accountHome.account') do |page|
    response = page.form_with(:action => 'https://www.myprotein.jp/elysiumAuthentication.login') do |form|
        form.field_with(id: 'username').value = ENV["MYPROTEIN_USER"]
        form.field_with(id: 'password').value = ENV["MYPROTEIN_PW"]
    end.submit
end

# コードの抽出
page = agent.get('https://www.myprotein.jp/my.basket') #=> Mechanize::Page
discountWidget = page.search('//*[@id="nav"]/div[4]/div[1]/div[3]/a/text()').inner_text
/割引コード：/ =~ discountWidget
/[A-Z]{3,8}[0-9]{1,2}/ =~ $'
discountCode = Regexp.last_match(0)

# コードの反映
form = page.form_with!(id: "discount-form") #=> Mechanize::Page
form.field_with(id: 'discountcode').value = discountCode
discounted_page = agent.submit(form)
price = discounted_page.search('//*[@id="mainContent"]/div[2]/div[3]/div/div[1]/div/div[1]/div[2]').inner_text
