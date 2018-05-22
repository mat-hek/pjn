import gensim.utils
from gensim.summarization import textcleaner
from gensim.models.phrases import Phrases, Phraser
from gensim.models import Word2Vec, KeyedVectors
from sklearn.manifold import TSNE
import matplotlib.pyplot as plt


dump_base = "/Users/mathek/Desktop/shit/agh/pjn/repo/dump/ex9/"


def mk_bigrams():
    with open(dump_base + "judgments", 'r', encoding="utf-8") as f:
        judgments = f.read()

    sentences = [list(gensim.utils.simple_tokenize(s)) for s in textcleaner.split_sentences(judgments)]

    bigramer = Phraser(Phrases(sentences))

    bigramer.save(dump_base + "bigramer")

    return [bigramer[s] for s in sentences]


def mk_model(sentences):
    model = Word2Vec(sentences, size=300, window=5, min_count=3, workers=4, sg=0)
    model.save(dump_base + "model")


def parse(expr: str):
    return expr.replace(" ", "_")


def read_wv():
    return Word2Vec.load(dump_base + "model").wv


def most_similar(expr, wv: KeyedVectors):
    return wv.most_similar(parse(expr), topn=3)


def rem_add(x, rem, add, wv: KeyedVectors):
    y = wv[parse(x)] - wv[parse(rem)] + wv[parse(add)]
    return wv.similar_by_vector(y, topn=5)


def surface_proj(exprs, wv: KeyedVectors):
    vectors = [wv[parse(e)] for e in exprs]
    points = TSNE(n_components=2).fit_transform(vectors)
    [x, y] = list(zip(*points))
    fig, ax = plt.subplots()
    ax.scatter(x, y)

    for [x, y], e in zip(points, exprs):
        ax.annotate(e, (x, y))

    plt.show()
