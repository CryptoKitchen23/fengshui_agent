# TODO:
# Add Tung Shing yellow calendar to analyze the fortune of the day or the 8 characters Coin birthday

# Reference 1: https://github.com/OPN48/cnlunar/blob/master/cnlunar/lunar.py
# Reference 2: https://github.com/6tail/lunar-python
# API 1: 中国老黄历 https://www.tianapi.com/apiview/45
# API 2: 黄历查询 https://www.jisuapi.com/api/huangli/

require 'net/http'
require 'json'

class YelloCalendarService
  YELLO_API_URL = "https://apis.tianapi.com/lunar/index?key="
  YELLO_API_KEY = Rails.application.credentials.dig(:api_key)

  def fetch_calendar_info
    uri = URI("#{YELLO_API_URL}#{YELLO_API_KEY}")
    response = Net::HTTP.get(uri)
    result = JSON.parse(response)["result"]

    {
      gregoriandate: result["gregoriandate"],
      lunardate: result["lunardate"],
      lunar_festival: result["lunar_festival"],
      festival: result["festival"],
      fitness: result["fitness"],
      taboo: result["taboo"],
      shenwei: result["shenwei"],
      taishen: result["taishen"],
      chongsha: result["chongsha"],
      suisha: result["suisha"],
      wuxingjiazi: result["wuxingjiazi"],
      wuxingnayear: result["wuxingnayear"],
      wuxingnamonth: result["wuxingnamonth"],
      xingsu: result["xingsu"],
      pengzu: result["pengzu"],
      jianshen: result["jianshen"],
      tiangandizhiyear: result["tiangandizhiyear"],
      tiangandizhimonth: result["tiangandizhimonth"],
      tiangandizhiday: result["tiangandizhiday"],
      lmonthname: result["lmonthname"],
      shengxiao: result["shengxiao"],
      lubarmonth: result["lubarmonth"],
      lunarday: result["lunarday"],
      jieqi: result["jieqi"]
    }
  end
end