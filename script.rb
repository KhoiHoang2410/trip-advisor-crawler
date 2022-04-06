require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'uri'
require 'json'
require 'csv'

PAGES_NUMBER = 10.freeze
OUTPUT_FILE = 'result_test.csv'.freeze
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
  request["Accept"] = "*/*"
  request["Accept-Language"] = "en-US,en;q=0.9,vi;q=0.8"
  request["Cookie"] = "TADCID=j6N_LCJ5_kaWm2foABQCFdpBzzOuRA-9xvCxaMyI12yn32CiG3wSuW3zwU7KjMvAjNEmnatTdqU-zLptL6kQ0sP8G7sDoATcfv4; TAUnique=%1%enc%3A4k9RwGwOWkXz36BDU%2B9jrtyKGP%2BleEjrCjkytB40cVdd2WxKjWsMvw%3D%3D; TASSK=enc%3AANKMdmkgZyUEYt%2BPSTonIdpSZfd0uOCycM5OXWcMdKIqME5sGYcgd9%2B87HPOVjQtG2%2BW2%2B%2FwHtetrG06N%2BXD62ydXZPKht3kyDwpU0CvMiW4QJuJxfbvAgUebW7dogndAQ%3D%3D; ServerPool=C; PMC=V2*MS.71*MD.20220406*LD.20220406; TATravelInfo=V2*AY.2022*AM.4*AD.23*DY.2022*DM.4*DD.24*A.2*MG.-1*HP.2*FL.3*DSM.1649265776060*RS.1; TASID=C2C297357D514A6FA8B04EF0EDFAD05F; TAReturnTo=%1%%2FHotel_Review-g293928-d13340256-Reviews-Ariyana_Smartcondotel_Nha_Trang-Nha_Trang_Khanh_Hoa_Province.html; ak_bmsc=E9B330D9217064BAEB83F14BA6AC933A~000000000000000000000000000000~YAAQrCg0Fy5MxNl/AQAATpjm/w8aiqxNbfo3b8XL2tINSdA8YrL4jbI5hJabOfjpNdL+l0j47Q1aqL9E2H0NsVFc/dsAWT19orQDkM6VJfk4Idg6cEpGQ6Ui4yc8E2q/pxNYYE92s15MZpSLhBCAb5ltHRfq+q7pOEPPYSYj9GAuU/vt3O+1EKMp/w1kz5ptEBCNYGSM9z8X3xX96rx8ZdhZP+qUE5+uZb5n4tbEq82iZjUF43dL6byPKqL4c8ajsnvry1MOfRiqVklLjWVl3OyIb9YbiG17rwfyhKY/5VFIkD9F8H53hJnH4teH0MI87rc0ytMqaHv9vDlFHlBs2BTumHnl22h4AC6NovVMKT4hcDXx6l2Rjl2+TqNMV+H2fODsCG4tQvbvrtOCiKn1y0D5Rw==; roybatty=TNI1625!ALjCeuiQU%2Frc6vsLyZLqwzNrpoNEKF1pkB5xm8NfKQEReMyhpVxnpAY7wzZNWLpZnpcIVACRm8qeQwODROj4WwFXT53mIFbAm1%2FgFYzU3t5MNYecFUd%2BWbSgWmTHVEoI89dv5IyRbykllqIW4Yz2pQlAt28s0T3xQERtrPNGeDda%2C1; PAC=AI_tg-UqZ7WojjvNhTa0YxaPFsWBu9YAUNyvVGtTzcqcprdrBv0dbs1fQQMCSOJoXXSo1qOYj6-f1S2J2JeekyVkZui79wXiLyPA3YfDMlX-W71YhQNhaBvIIvZgOlUD_O03lV9VJHVHYo7RIXAChu9vhvNbn_ktvyrjAgRJjO5XGusgHq3YaheCQZDsH0neZjl959Otcbi4ceE2QTIjX8bJuRn5qbNYHQRv9WkSXi_vph9fMvsCIuIRV2cVVsxhPrLMxrPzpdrxwh6RPFJSjCU%3D; TATrkConsent=eyJvdXQiOiIiLCJpbiI6IkFMTCJ9; TART=%1%enc%3AKQVDKAxiMUre8i4vrfxsd%2BXuNWqQPbEOkGo9Ywki%2BN6rMcA8qw44g4Vsw9HUC%2B35zJHrnPxvWuA%3D; _pbjs_userid_consent_data=3524755945110770; _li_dcdm_c=.tripadvisor.com.vn; _lc2_fpi=28c87295fd99--01fzzydbkq8whkkkx6n3zfran7; __gads=ID=c843440e8fa70f80:T=1649265783:S=ALNI_MZ0OqYzh22U2CXpWVaRR6l6k_tfQA; TASession=V2ID.C2C297357D514A6FA8B04EF0EDFAD05F*SQ.4*LS.DemandLoadAjax*GR.89*TCPAR.38*TBR.71*EXEX.41*ABTR.37*PHTB.13*FS.37*CPU.12*HS.recommended*ES.popularity*DS.5*SAS.popularity*FPS.oldFirst*LF.vi*FA.1*DF.0*TRA.true*LD.13340256*EAU._; TAUD=LA-1649265778394-1*RDD-1-2022_04_07*HDD-1-2022_04_23.2022_04_24.1*LD-5097-2022.4.23.2022.4.24*LG-5099-2.1.F.; _lr_sampling_rate=100; _lr_retry_request=true; _lr_env_src_ats=false; __li_idex_cache=%7B%7D; pbjs_li_nonid=%7B%7D; __vt=s7P_hGlSoCWKOkn2ABQCIf6-ytF7QiW7ovfhqc-AvRyFhF6hKtUIdCVAVqCYwhOi8faa8DUZYQpFukh2luoltWsXJJm8IpUYgRYJZ61HhirxS9Czh3n-kT1YFxNWFVWngoqsBEJZQrkjuNuWMXvcB5MdkAw; bm_sv=1543AD9F66EDBF55EF761DCC4BA93E85~7OrJce6R0/wSqw4YY9WbKXCs6NllYeig/W04Nmbv8Gz34OsXNf1MnUFtfbaqolU4MjMxUkArRjd2Djz8TqoMb+v4/+9blTbyAlmQVPj6jzWX3wGJI2gK4blKXQNPmK+v8k7vTzTVijEkf/6WBo7Kw2SMM5EGPOPx8Uy4QW+JBHw=; bm_sv=1543AD9F66EDBF55EF761DCC4BA93E85~7OrJce6R0/wSqw4YY9WbKXCs6NllYeig/W04Nmbv8Gz34OsXNf1MnUFtfbaqolU4MjMxUkArRjd2Djz8TqoMb+v4/+9blTbyAlmQVPj6jzWX3wGJI2gK4blKXQNPmK+vDSeU0csGh4JdcbaFi68mS8Ee2+CK8C9L0juLfWWA6vY=; TASID=C2C297357D514A6FA8B04EF0EDFAD05F; __vt=u67vGEu51709JLNmABQCIf6-ytF7QiW7ovfhqc-AvRyFi5Lyw55AJEm7bA2m0Ai5yPV3fxhY9yVsgfvmrV-tMYloYEpKXGc5WGxF0SYoMyQVQ76rWhDu2FF6usi46mZ2xtJ_0vtQ1UL26DaP-V1SpFwxUaw"
  request["Origin"] = "https://www.tripadvisor.com.vn"
  request["Referer"] = "https://www.tripadvisor.com.vn/Hotel_Review-g293928-d13340256-Reviews-or10-Ariyana_Smartcondotel_Nha_Trang-Nha_Trang_Khanh_Hoa_Province.html"
  request["Sec-Ch-Ua"] = "\" Not A;Brand\";v=\"99\", \"Chromium\";v=\"100\", \"Google Chrome\";v=\"100\""
  request["Sec-Ch-Ua-Mobile"] = "?0"
  request["Sec-Ch-Ua-Platform"] = "\"macOS\""
  request["Sec-Fetch-Dest"] = "empty"
  request["Sec-Fetch-Mode"] = "cors"
  request["Sec-Fetch-Site"] = "same-origin"
  request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.60 Safari/537.36"
  request["X-Requested-By"] = "TNI1625!AGEuZ/SG/eilpZI3MhwywtfJuanqF4V9tBDSoXPkK0LPix3hIyRJhL3mD/3JDFQwM1Ma96s9CvErZeozA0B+Y7ndhHErKbjrYotJlhgJPj565RAX2HSk3cIxIp9eSh+dHyDG29nCfrslCl8jFgbOApdO7Ag69Ot+UIVWBT/Nw+v7"

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

      item_count = 0
      JSON.parse(response.body)
        .to_a[1]
        .to_h['data']
        .to_h['locations']
        .to_a[0]
        .to_h['reviewListPage']
        .to_h['reviews']
        .to_a
        .each do |review|
          item_count += 1
          csv << csv_adapter(review, hotel)
        end

      puts "Successed fetch #{item_count} review(s)"

      break if item_count < 20
    end

    puts ""
    puts "Done"
  end
end
