from BeautifulSoup import BeautifulSoup
from nltk.stem.porter import PorterStemmer
from nltk.tokenize import RegexpTokenizer
import re

def stemWord(word):
    return PorterStemmer().stem(word)

def remove_html(html_tags):
	VALID_TAGS = []
	soup = BeautifulSoup(html_tags)
	for tag in soup.findAll(True):
	    if tag.name not in VALID_TAGS:
	        tag.replaceWith(tag.renderContents())
	return soup.renderContents();

#source: https://twitter-sentiment-analysis.googlecode.com/svn-history/r51/trunk/files/stopwords.txt
stop_words_list = ["about", "after", "again", "all",
"am", "an", "and", "any", "are", "as", "at", "be", "because", "been", "before",
"being", "below", "between", "both", "but", "by", "could", "did", "do", "does",
"doing", "down", "during", "each", "few", "for", "from", "further", "had",
"has", "have", "having", "he", "he'd", "he'll", "he's", "her", "here", "here's",
"hers", "herself", "him", "himself", "his", "how", "how's", "i", "i'd",
"i'll", "i'm", "i've", "if", "in", "into", "is", "it", "it's", "its", "itself",
"let's", "me", "more", "most", "my", "myself", "of", "off",
"on", "once", "only", "or", "other", "ought", "our", "ours", "ourselves", "out",
"over", "own", "same", "she", "she'd", "she'll", "she's", "should", "so", "some",
"such", "that", "that's", "the", "their", "theirs", "them", "themselves",
"then", "there", "there's", "these", "they", "they'd", "they'll", "they're",
"they've", "this", "those", "through", "to", "too", "under", "until", "up",
"very", "was", "we", "we'd", "we'll", "we're", "we've", "were", "what", "what's",
"when", "when's", "where", "where's", "which", "while", "who", "who's", "whom",
"why", "why's", "with", "won't", "would", "you", "you'd", "you'll", "you're",
"you've", "your", "yours", "yourself", "yourselves", "obama", "barak", "mitt", "romney" ]

def clean_training_data(training_tweets):
	tweets = []
	for(data, data_class) in training_tweets:
		try:
			cleaned_data = []
			#remove hash tags
			#data = re.sub("#\w+","",data)
			#trying to only remove # symbol and not the tag word
			#print "Data (remove hash tags): ",data
			#remove @user tags
			data = re.sub("@\w+","",data)
			#print "Data (remove @user tags): ",data
			#remove numbers
			data = re.sub("\d+","",data)
			#print "Data (remove numbers): ",data

			#remove html tags
			data = remove_html(data)

			#remove urls/links
			data = re.sub("https?://[^\s]+","",data)
			#print "Data (remove urls): ",data
			
			#remove special characters
			data = re.sub("[.!$%^&*()_+-=~,\?\']+","",data)
			#print "Data (remove special characters): ",data

			#convert to small letters
			data = data.lower();
			#print "Data (lower case): ",data
			#tokenize data
			data_tokens = tokenizer.tokenize(data)
			clean_words = []
			for t in data_tokens:
				#if t.startswith('#') or t.startswith('@') or t in stop_words_list: continue
				if t.startswith('@') or t in stop_words_list: continue
				t = stemWord(t)
				if len(t) > 2:
					clean_words.append(t)
			tweets.append((clean_words, data_class))

		except Exception, e:
			#print "---Variable Type : %s" %  type (data)
			#print len(data)
			pass
	return tweets


def clean_test_data(training_tweets):
	tweets = []
	for(data) in training_tweets:
		cleaned_data = []
		#remove hash tags
		#data = re.sub("#\w+","",data)
		#trying to only remove # symbol and not the tag word
		#remove @user tags
		data = re.sub("@\w+","",data)
		#remove numbers
		data = re.sub("\d+","",data)
		#remove html tags
		data = remove_html(data)
		#remove urls/links
		data = re.sub("https?://[^\s]+","",data)
		#remove special characters
		data = re.sub("[#.!$%^&*()_+-=~,\?\']+","",data)
		#convert to small letters
		data = data.lower();
		#tokenize data
		data_tokens = tokenizer.tokenize(data)
		clean_words = []
		for t in data_tokens:
			if t.startswith('@') or t in stop_words_list: continue
			t = stemWord(t)
			if len(t) > 2:
				clean_words.append(t)
		tweets.append((clean_words))
	return tweets

tokenizer = RegexpTokenizer(r"[A-Z]{2,}(?![a-z])|[A-Z][a-z]+(?=[A-Z])|[\'\w\-]+")