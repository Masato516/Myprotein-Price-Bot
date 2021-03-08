require 'mechanize'
require 'nokogiri'
require 'dotenv'

module Crawler
    def login #=> 戻り値: agent
        login_uri = 'https://www.myprotein.jp/accountHome.account'
        agent = Mechanize.new
        puts agent.class
        agent.user_agent_alias = 'Mac Safari'
        # ログイン
        agent.get(login_uri) do |page|
            response = page.form_with(:action => 'https://www.myprotein.jp/elysiumAuthentication.login') do |form|
                form.field_with(id: 'username').value = ENV["MYPROTEIN_USER"]
                form.field_with(id: 'password').value = ENV["MYPROTEIN_PW"]
            end.submit
        end
        return agent
    end #=> 戻り値: discountCode, page #=> 引数: agent

    def get_page(page_uri, agent)
        # コードの抽出
        puts agent.cookies()
        puts agent.cookie_jar()
        page = agent.get(page_uri)
    end
    
    def find_discountCode(page)
        discountWidget = page.search('//*[@id="nav"]/div[4]/div[1]/div[3]/a/text()').inner_text
        /割引コード：/ =~ discountWidget
        /[A-Z]{3,8}[0-9]{1,2}/ =~ $'
        discountCode = Regexp.last_match(0)
    end

    def discount(page, agent, discountCode) #=> 戻り値: price, #=> 引数: page, agent
        # コードの反映
        form = page.form_with!(id: "discount-form") #=> Mechanize::Page
        form.field_with(id: 'discountcode').value = discountCode
        discounted_page = agent.submit(form)
        price = discounted_page.search('//*[@id="mainContent"]/div[2]/div[3]/div/div[1]/div/div[1]/div[2]').inner_text
    end
    module_function :login, :get_page, :find_discountCode, :discount
end

