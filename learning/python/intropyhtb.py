# Welcome
## print("Hello Academy!")
# Hello Again, Academy
## greeting = "Hello again, Academy"
## print(greeting)
## a = "HTB"
## b = "Academy"
## print(a, b)
## Use #!/usr/bin/env python3 on Linux to execute the code without typing "python" in the terminal.
# A Few Simple Variables
## advice = "Don't panic"
## ultimate_answer = 42
## potential_question =  6 * 7
## confident = True
## something_false = False
## problems = None
# Latest expression can be the variable "_" in IDLE i.e:
## 38 + 4
## 50 - _

# Conditional statements and Loops
# If-Else
## happy = True
## if happy: # Shorthand of happy == True
##     print("Happy and we know it!")
## else:
##     print("Not happy...")
# If-elif-else
## happy = 2
## if happy == 1:
##     print("Happy and we know it !")
## elif happy == 2:
##     print("Excited about it!")
## else:
##     print("Not happy...")
# While-Loop
## counter = 0
## while counter < 5:
##     print(f'Hello #{counter}') # f(ormat)-string: populate a strign with values during runtime
##     counter = counter + 1
# Format Strings
## print("What's your name?")
## me = input()
## greeting = f'Hello {me}!'
## print(greeting)
# List of Strings
## groceries = ['Walnuts', 'Grapes', 'Bird seeds']
## print(groceries[2])
# Loop to reverse a string
# While version
## var = "Julián"
## i = len(var) -1
## while i >= 0:
##     print(var[i])
##     i -= 1
# For version
## var = "Julián"
## for i in range(len(var) - 1, -1, -1):
##     print(var[i])
# Slicing
## var = "Julián"
## print(var[::-1])
# for-each loop
## groceries = ['Walnuts', 'Grapes', 'Bird seeds']
## for food in groceries:
##     print(f'I bought some {food} today.')

# Defining functions
## Password Generator Example
## wordlist = ['password', 'john', 'qwerty', 'admin']
## for word in wordlist:
##     counter = 0
##     while counter < 100:
##         print(f'{word}{counter}')
##         counter += 1 
## 
## def f(x):
##     return 2 * x + 5
## def power_of(x, exponent):
##     return x ** exponent
## 
## print(f(2))
## print(power_of(2, 4))
## 
## #Invitation
## def print_sample_invitation(mother, father, child, teacher, event):
##     sample_text = f'''
##     Dear {mother} and {father}.
##     {teacher} and I would love to see you both as well as {child} at our {event} tomorrow evening.
## 
##     Best regards,
##     Principal G. Sturgis.
##     '''
##     print(sample_text)
## print_sample_invitation(mother='Karen', father='John', child='Noah', teacher='Tina', event='Pizza Party')
## 
## class DreamCake:
##     eggs = 4
##     sugar = 300
##     milk = 200
##     butter = 50
##     flour = 250
##     baking_soda = 20
##     vanilla = 10
## 
##     topping = None
##     garnish = None
## 
##     is_baked = False
## 
##     def __init__(self, topping='No topping', garnish='No garnish'):
##         self.topping = topping
##         self.garnish = garnish
##     
##     def bake(self):
##         self.is_baked = True
##     
##     def is_cake_ready(self):
##         return self.is_baked
## 
## ## Establecemos valores a los atributos topping y garnish de la tarta
## chocolate_cake = DreamCake(topping="Strawberry frosting", garnish="Chocolate chips")
## print(chocolate_cake.topping, chocolate_cake.garnish, chocolate_cake.is_cake_ready())
## ## Llamamos a la función "bake" para cambiar el valor de is_baked de "False" a "True"
## chocolate_cake.bake()
## print(chocolate_cake.is_cake_ready())
## 
## class Circle():
##     def __init__(self, radius):
##         self.radius = radius
## 
##     def __str__(self):
##         return f'Circle(r={self.radius})'
## 
## my_circle = Circle(radius=5)
## print(my_circle)
## 
## class Foo():
##     def __enter__(self):
##         print("Enter...")
##     
##     def __exit__(self, type, value, traceback):
##         print("... and exit.")
## 
## with Foo():
##     print("Hello world!")
# Importing a Library
## import datetime
## dir(datetime) ---> On IDLE
## now = datetime.datetime.now()
## print(now) 

# Importing a Class from a Library
## from datetime import datetime
## print(datetime.now())

# Giving it a new name
## from datetime import datetime as dt
## print(dt.now())

# Requests package
## (I have to make sure to delete the requests package after the module (python3 -m pip uninstall requests))
## import requests
## resp = requests.get('http://httpbin.org/ip')
## print(resp.content.decode())

# Prints:
## {
##     "origin": "X.X.X.X"
## }

# BeautifulSoup Package
## (I have to make sure to delete the requests package after the module (python3 -m pip uninstall beautifulsoup4))
## from bs4 import BeautifulSoup
## html_doc = """ 
## <html>
## <head><title>Birbs are pretty</title></head>
## <body><p class="birb-food"><b>Birbs and their foods</b></p>
## <p class="food">Birbs love:<a class="seed" href="http://seeds" id="seed">seed</a>
##    and 
##    <a class="fruit" href="http://fruit" id="fruit">fruit</a></p>
##  </body></html>
##  """
## soup = BeautifulSoup(html_doc, 'html.parser')
## print(soup.prettify()) 

# The First Iterations
## Printing Web Page Source Code
import requests
from bs4 import BeautifulSoup
import re

PAGE_URL = "https://www.deepl.com/en/translator"

# Defining the function to get the HTML out of an url

def get_html_of(url):
    resp = requests.get(url)
    if resp.status_code != 200:
        print(f'HTTP status code of {resp.status_code} returned, but 200 was expected. Exiting...')
        exit(1)
    return resp.content.decode()

# Setting up variables in order to get the content of the html and the one which counts the words of the html.

html = get_html_of(PAGE_URL)
soup = BeautifulSoup(html, 'html.parser')
raw_text = soup.get_text()
all_words = re.findall(r'\w+', raw_text) # r' ' stands for "r"aw string.

word_count = {} # Declared a new variable that acts like an empty dictionary

for word in all_words:
    if word not in word_count: # Going through each word in all_words
        word_count[word] = 1 # Checking if it NOT (in the if declaration says not in) exists already
    else:
        current_count = word_count.get(word) # if it exists we get the current value set of word 
        word_count[word] = current_count + 1 # Increment the value of word by one

# We can cut down the above code to the following to lines:
# for word in all_words:
#    word_count[word] = word_count.setdefault(word, 0) + 1

top_words = sorted(word_count.items(), key=lambda item: item[1], reverse=True)
for i in range(10):
    print(top_words[i][0])