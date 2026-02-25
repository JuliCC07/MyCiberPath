## Printing Web Page Source Code
import requests
from bs4 import BeautifulSoup
import re
import click

# Defining the function to get the HTML out of an url

def get_html_of(url):
    resp = requests.get(url)
    if resp.status_code != 200:
        print(f'HTTP status code of {resp.status_code} returned, but 200 was expected. Exiting...')
        exit(1)
    return resp.content.decode()

# Setting up functions in order to get the content of the html and the one which counts the words of the html.

def count_occurrences_in(word_list, min_length):
    word_count = {} # Declared a new variable that acts like an empty dictionary

    for word in word_list:
        if len(word) < min_length:
            continue # if a word is shorter than our minimum length, continue wouldn't add it to the word_count dictionary.
        if word not in word_count: # Going through each word in all_words
            word_count[word] = 1 # Checking if it NOT (in the if declaration says not in) exists already
        else:
            current_count = word_count.get(word) # if it exists we get the current value set of word 
            word_count[word] = current_count + 1 # Increment the value of word by one
    return word_count
# We can cut down the above code to the following to lines:
# for word in all_words:
#    word_count[word] = word_count.setdefault(word, 0) + 1

def get_all_words_from(url):
    html = get_html_of(url)
    soup = BeautifulSoup(html, 'html.parser')
    raw_text = soup.get_text()
    return re.findall(r'\w+', raw_text) # r' ' stands for "r"aw string.

def get_top_words_from(all_words, min_length):
    occurrences = count_occurrences_in(all_words, min_length)
    return sorted(occurrences.items(), key=lambda item: item[1], reverse=True)
    
@click.command()
@click.option('--url', '-u', prompt='Web URL', help='URL of webpage to extract from.')
@click.option('--length', '-l', default=0, help='Minimum word length (default: 0, no limit.)')
@click.option('--output', '-o', default=None, help='Define the output file where you want to store the data')
def main(url, length, output):
    the_words = get_all_words_from(url)
    top_words = get_top_words_from(the_words, length)    
    resultado = "\n".join(top_words[i][0] for i in range(10))
    if output != None:
        with open(output, 'w') as wr:
            wr.write(resultado + "\n")
    else:   
        print(resultado)

if __name__ == '__main__':
    main()