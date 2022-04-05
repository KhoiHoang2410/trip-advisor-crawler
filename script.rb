require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'uri'
require 'json'
require 'csv'

PAGES_NUMBER = 10.freeze
OUTPUT_FILE = 'result.csv'.freeze
HEADERS = ['User name', 'User location', 'Trip date', 'Trip type', 'Rating', 'Review', 'Hotel name'].freeze

def get_hotels
  File.open('list_hotel').read.split("\n").map do |text|
    p = text.match(/(.*) https.*-g(\d*)-d(\d*)/)
    {
      name: p[1],
      geo_id: p[2],
      location_id: p[3]
    }
  end
end

def get_curl(hotel, page)
  uri = URI.parse("https://www.tripadvisor.com.vn/data/graphql/ids")
  request = Net::HTTP::Post.new(uri)
  request.content_type = "application/json"
  request["Authority"] = "www.tripadvisor.com.vn"
  request["Sec-Ch-Ua"] = "\" Not A;Brand\";v=\"99\", \"Chromium\";v=\"99\", \"Google Chrome\";v=\"99\""
  request["Sec-Ch-Ua-Mobile"] = "?0"
  request["X-Requested-By"] = "TNI1625u0021AFozMp9aJtegnHP3KbYUYK3WVqd+KJN6jtkOzEp7I46L7LPhItk+z6TrVQxPZbJStu8KRXq2K51+EHl32nFPIw643WsDyIBk+trxUV2aTLYTn0jjXwipXOlx7R+fHFDcelxBsE7w/w0fktuKTRBRAIB6QpjdKBdLj85wYaW1NwI2"
  request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.74 Safari/537.36"
  request["Sec-Ch-Ua-Platform"] = "\"macOS\""
  request["Accept"] = "*/*"
  request["Origin"] = "https://www.tripadvisor.com.vn"
  request["Sec-Fetch-Site"] = "same-origin"
  request["Sec-Fetch-Mode"] = "cors"
  request["Sec-Fetch-Dest"] = "empty"
  request["Referer"] = "https://www.tripadvisor.com.vn/Hotel_Review-g293928-d7824148-Reviews-or35-Liberty_Central_Nha_Trang_Hotel-Nha_Trang_Khanh_Hoa_Province.html"
  request["Accept-Language"] = "en-US,en;q=0.9,vi;q=0.8"
  request["Cookie"] = "TADCID=alieGgRzYQrljAgnABQCFdpBzzOuRA-9xvCxaMyI12xQyuz57GXfAQb34Y5dDuqvDZhvoAPJixQi_tr8g3bk1Q4AIgaxe5YrZD4; TAUnique=%1%enc%3AZfQfdNxLjPi3uUEU%2FxSq9nJogK0wBHRu1ZnjE1%2FrPktakManzBVKtw%3D%3D; TASSK=enc%3AAInMpGBVupIg4pQdzAl8SUp0ahQh7l1OCBmKbrwA1rBfDn3DGEl6AS7SdGmG9IJIfCIXvCwjdskXeBGrApwHgN%2BlJq%2FL0WqFxVrLosUjCbI2yos2HhJRVv%2FR%2FLc%2FJehcWw%3D%3D; ServerPool=X; PMC=V2*MS.92*MD.20220322*LD.20220322; TART=%1%enc%3At7lBFP8UqvaFTlc3b37cgBAKnBu%2F6b3YnYflHaWMPz0PRmv8HVG8MQDCGvVHNnnRn3s0zCf%2Bf1Q%3D; TATrkConsent=eyJvdXQiOiIiLCJpbiI6IkFMTCJ9; _pbjs_userid_consent_data=3524755945110770; _li_dcdm_c=.tripadvisor.com.vn; _lc2_fpi=28c87295fd99--01fyr2rsq8nf5af25z65eqw8m3; __gads=ID=c0cf947d18cf8897:T=1647928174:S=ALNI_MaQfBkpekYu9-9W8RH1g562eiglgQ; _lr_sampling_rate=100; _lr_env_src_ats=false; pbjs_li_nonid=%7B%7D; TATravelInfo=V2*AY.2022*AM.4*AD.1*DY.2022*DM.4*DD.2*A.2*MG.-1*HP.2*FL.3*DSM.1647928508076*RS.1; TASID=FE8C78AC842E453AA3A443876859EBE9; ak_bmsc=C3B3041989BDA4911198D6300DF3075C~000000000000000000000000000000~YAAQP809F/qhkpl/AQAAXpnAsQ9f2WkuEgWvEcitiZs2FmZteaNLbJgAjPwi/BGFa7ZfRs2ZP62ZDRnUJM+wWHSIBNkBBm4WccpwxMP3zWKv022oDOIQs8KhNJlx7FGz+Fr4JgC/E3xpbYinLt7e9IiBpor0HDNidmoJuYHWCkrPvoAJ7/2tzgkShZmlMiteVMuakOtrUcU0O+oTDFvqefybwisyX8/cRNPHvfWH9VLiqX75ogPYqbGal47U1xMh8a9gwqrc7DZ5iAx07D6fGeF5qtkZQ6zmMRpJZbZfhyON1EOC1yROt6dWGgKJRprhrfgfldX4Hl1PQI2ZV+7LZR0lZRpQD5ICCjeSj6cIrZ8eJpt4pXlJRsbdjxoDMNHPBeuACAhgRBSc1h3Dx0HcH87iVg==; _lr_retry_request=true; bm_sv=A5B0B5539025D6D5FA5EF1BC2ADF6C53~bbzaRuzj6fJSPy5uDMmW3TgsTL7yspeHRotSu+nD92K6+tPBOnNfyX98roJAl5yjrxbNPUjVpsTqOOMc9Qa+ILxHn+25nfOZlD3VmjwkgMKui/gYzH+oOqYhX4Z+MNo3BebmsD0eBIbrw5zSnNj2pAFMYmcE7CnsmCM4oufjdls=; PAC=AOar_QrDBw9IxX_WfFY48WgYJXfq0Y-qma6OZLfnter0iPBnpN__N3PyAR4SOfztGNdt9NiVTaFBwKVz_uJj8VayehJYlLZQ2OSJ48jp_e6eV9X37xjbOr_QBdau5O9f9n_5HCjtaj7xz6ukl-1FuYPKkyPyfb4A2eVm8cuYbrG13QsQsnOmEk8AFwa_AsWZVrXk76R9l-oLdas36k5lanBaZD7m8RHHsuZJLVIOvIETlg-Y244sR2GbpfeVbOI4SkIgrOWB7u6Rl-yZCgtziuc%3D; __vt=RRJ5ijgdItuRvzHBABQCIf6-ytF7QiW7ovfhqc-AvRwwWRObEF3wKg5DtNmlkRGOWnXOwfXBXsMccAZ0zQDMHG93ZSl7hfzCvg1l_48Kz9W9slo1c2LflA-IwxOHQzXon4NHhwOk8TkL6fNq5p4Zaji0YQ; TAReturnTo=%1%%2FHotel_Review-g293928-d7824148-Reviews-or15-Liberty_Central_Nha_Trang_Hotel-Nha_Trang_Khanh_Hoa_Province.html; roybatty=TNI1625u0021AOLsc9VuNLDAjrFpJT5na2nmhla8s%2Fs0ab7j7EW6EPM4thE6QxDWb7LAIDKTaB1cCOnZOG82VLASZ6oPZcmjdtz8DUsuokq%2BgHvg1CD9opLsA06z054qAf3aGueZYmuNPeUyo2zlLcezUfkMtDRbMGwDwlJRYjhFdg9GlhdslW93%2C1; TASession=V2ID.FE8C78AC842E453AA3A443876859EBE9*SQ.72*LS.PageMoniker*GR.24*TCPAR.71*TBR.84*EXEX.67*ABTR.75*PHTB.68*FS.34*CPU.23*HS.recommended*ES.popularity*DS.5*SAS.popularity*FPS.oldFirst*LF.vi*FA.1*DF.0*TRA.true*LD.7824148*EAU._; SRT=%1%enc%3At7lBFP8UqvaFTlc3b37cgBAKnBu%2F6b3YnYflHaWMPz0PRmv8HVG8MQDCGvVHNnnRn3s0zCf%2Bf1Q%3D; TAUD=LA-1647928173031-1*RDD-1-2022_03_22*HDD-29237289-2022_04_01.2022_04_02.1*LD-29715685-2022.4.1.2022.4.2*LG-29715687-2.1.F.; bm_sv=A5B0B5539025D6D5FA5EF1BC2ADF6C53~bbzaRuzj6fJSPy5uDMmW3TgsTL7yspeHRotSu+nD92K6+tPBOnNfyX98roJAl5yjrxbNPUjVpsTqOOMc9Qa+ILxHn+25nfOZlD3VmjwkgMKui/gYzH+oOqYhX4Z+MNo3DN+EwS5eL+vimaHyMj08xvimcO3WW51puTmqKJ1OYf8=; TASID=FE8C78AC842E453AA3A443876859EBE9; __vt=g8LCFcNqPDa3jWPpABQCIf6-ytF7QiW7ovfhqc-AvRwwc8NnRTzob3tGOxkYpGQOQjXnbF_3UIxCSRApqQDuLedfH35eufw-C5jcABgnt7kzbfRtqGC7KCviwO8OBRdwOON0Ao3qyzgNH5SlqAl14KMI4Q"

  req_options = {
    use_ssl: uri.scheme == "https",
  }

  request_body = JSON.parse(
    File.read('request_body')
      .gsub('XX_LOCATION_ID', hotel[:location_id])
      .gsub('XX_GEO_ID', hotel[:geo_id])
      .gsub('XX_OFFSET', (20 * page).to_s)
  )

  [uri, req_options, request, request_body]
end

def csv_adapter(review, hotel)
  [
    review['userProfile'].to_h['displayName'],
    review['userProfile'].to_h['hometown'].to_h['location'].to_h['name'],
    review['tripInfo'].to_h['stayDate'],
    review['tripInfo'].to_h['tripType'],
    review['rating'],
    review['text'],
    hotel[:name]
  ]
end

CSV.open(OUTPUT_FILE, 'w') do |csv|
  csv << HEADERS

  get_hotels.each do |hotel|
    puts ""
    puts "Processing #{hotel[:name]}"

    (0...PAGES_NUMBER).each do |page|
      puts ""
      puts "Fetching page #{page + 1}"

      uri, req_options, request, request_body = get_curl(hotel, page)

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request, request_body.to_json)
      end

      unless (200..299).include?(response.code.to_i)
        puts "Page #{page + 1} not exist"
        break
      end

      puts "Successed"

      JSON.parse(response.body)
        .to_a[1]
        .to_h['data']
        .to_h['locations']
        .to_a[0]
        .to_h['reviewListPage']
        .to_h['reviews']
        .to_a
        .each do |review|
          csv << csv_adapter(review, hotel)
        end
    end

    puts ""
    puts "Done"
  end
end
