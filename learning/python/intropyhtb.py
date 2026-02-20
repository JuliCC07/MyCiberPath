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

