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

def get_soup_from(url):
    html = get_html_of(url)
    soup = BeautifulSoup(html, 'html.parser')
    return soup
def get_all_words_from(url):
    soup = get_soup_from(url)
    raw_text = soup.get_text()
    return re.findall(r'\w+', raw_text) # r' ' stands for "r"aw string.
# Extract links
def get_all_links_from(url):
    soup = get_soup_from(url)
    links = soup.find_all(name="a", attrs={"href": True})
    url_destino = []
    for link in links:
        url_destino.append(link["href"])
    return url_destino

def get_top_words_from(all_words, min_length):
    occurrences = count_occurrences_in(all_words, min_length)
    return sorted(occurrences.items(), key=lambda item: item[1], reverse=True)
# Mutating words
def mutating_words(word):
    variations = {word, word.lower(), word.upper(), word.capitalize()}
    sufixes = {"", "2024", "2025", "2026", "1!", "123"}
    mutated_words = []
    for variation in variations:
        for sufix in sufixes:
            new_word = variation + sufix    
            mutated_words.append(new_word)
    return mutated_words


@click.command()
@click.option('--url', '-u', prompt='Web URL', help='URL of webpage to extract from.')
@click.option('--length', '-l', default=0, help='Minimum word length (default: 0, no limit.)')
@click.option('--output', '-o', default=None, help='Define the output file where you want to store the data')
@click.option('--depth', '-d', default=1, help="Maximum depth of the link crawl")
def main(url, length, output, depth):
    the_words = get_all_words_from(url)
    top_words = get_top_words_from(the_words, length)
    
    top_10_words = top_words[:10]    
    
    resultado = "\n".join(item[0] for item in top_10_words)
    
    # Adding mutated words
    all_variations = []
    for item in top_10_words:
        mutations = mutating_words(item[0])
        all_variations.extend(mutations)
    resultado_mutaciones = "\n".join(all_variations)
    
    pending_links = [url]
    all_found_links = []
    visited_links = set()
    for level in range(depth):
        next_level_link = []
        for link in pending_links:
            if link not in visited_links:
                visited_links.add(link)
                new_links = get_all_links_from(link)
                next_level_link.extend(new_links)
                all_found_links.extend(new_links)
        pending_links = next_level_link

    resultado_links = "\n".join(set(all_found_links))

    if output != None:
        with open(output, 'w', encoding="utf-8") as wr:
            wr.write(
                # resultado + "\n" +
                # resultado_mutaciones + "\n" + 
                resultado_links + "\n"
                )
    else:   
        print(
            # resultado + "\n" + 
            # resultado_mutaciones + "\n" + 
            resultado_links + "\n"
            )


if __name__ == '__main__':
    main()