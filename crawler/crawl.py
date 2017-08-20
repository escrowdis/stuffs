from bs4 import BeautifulSoup
import urllib3

http = urllib3.PoolManager()
url = 'file:///C:/Users/User/Downloads/My104%E6%9C%83%E5%93%A1%E4%B8%AD%E5%BF%83%20-%20%E5%B7%A5%E4%BD%9C%20-%20%E5%84%B2%E5%AD%98%E5%B7%A5%E4%BD%9C%20-%20%E5%85%A8%E9%83%A8%E5%B7%A5%E4%BD%9C.html'

response = http.request('GET', url)
html = response.read()
soup = BeautifulSoup(html)