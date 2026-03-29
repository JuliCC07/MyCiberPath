## STRINGS

# print("""Hello World!!
# QUE COJONES LOCO
# WATAFAC
# MIBOMBO
# """)
# print("Esto \n" + "es " + "una \n" + "prueba")


# print("I am Poppy \n" * 100)

## Variables
# Ejercicio: Tienda de café no se por qué este tio está putammente loco
# Robot barista

print("Hello, welcome to Café")

name = input("What's your name? \n")

if name == "Ben":
    evil_status = input("Are you evil?\n")
    if evil_status == "Yes":
        print("Get the hell outta here")
        exit()
    else:
        print("Oh, so you're one of those good Bens. Come on in!")
else:
    print("Hello " + name  + ". Thank you for coming in today!!\n")
menu = " Café \n Té \n Latte"
print(name + ", what would you like from our menu today? here is what we are serving. \n" + menu + "\n")

order = input()

if order == "Café":
    price = 5
elif order == "Té":
    price = 6
elif order == "Latte":
    price = 4
else:
    print("Sorry, we don't have that here.")

quantity = input("How many "+ order + " would you like?\n")

print("Sounds good " + name + " We'll have your " + quantity + " " + order + " ready in a few minutes.")

total = price * int(quantity)

print("Thank you, your total is: " + str(total) + "€")

## Maths

# age = 18

# actual_age = 18.28

# math = 5 ** 7 + 12 - 9 / 40

# results = age + actual_age + math

# print(results)