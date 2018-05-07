import os
import networkx as nx
import matplotlib.pyplot as plt
import itertools


from pywnxml.WNQuery import *


def get_query():
    query = WNQuery("/Users/mathek/Desktop/shit/agh/pjn/plwordnet_3_1/plwordnet-3.1-visdisc.xml", log=open(os.devnull, "w"))
    query.writeStats(sys.stdout)
    return query


def szkoda_meanings(query: WNQuery):
    return query.lookUpLiteral('szkoda', 'n')


def closure(query: WNQuery, wnid, pos, relation):
    related_wnids = query.lookUpRelation(wnid, pos, relation)
    result = []
    for rwnid in related_wnids:
        result.extend([(wnid, rwnid)] + closure(query, rwnid, pos, relation))
    return result


def wypadek_drogowy_hypernym(query: WNQuery):
    wnid = query.lookUpSense("wypadek drogowy", 1, "n").wnid
    cl = closure(query, wnid, 'n', 'hypernym')
    cl = [(query.getSynset(a, 'n').toString(), query.getSynset(b, 'n').toString()) for (a, b) in cl]

    graph = nx.DiGraph()
    graph.add_edges_from(cl)
    plt.figure(figsize=(15, 10))
    nx.draw_spring(graph, arrows=True, with_labels=True)
    plt.show()


def relation(query: WNQuery, rel, wnid, pos, row=1):
    rwnids = query.lookUpRelation(wnid, pos, rel)
    if row == 1:
        return rwnids
    else:
        res = []
        for rwnid in rwnids:
            res.extend(relation(query, rel, rwnid, pos, row - 1))
        return res


def wypadek_hyponyms(query: WNQuery, row=1):
    wnid = query.lookUpSense("wypadek", 1, 'n').wnid
    hyponyms = relation(query, 'hyponym', wnid, 'n', row)
    return [query.getSynset(h, 'n') for h in hyponyms]


def show_relations(query: WNQuery, words):
    senses = itertools.groupby(words, lambda w: query.lookUpSense(w[:-2], int(w[-2]), w[-1]))
    senses = [(s, "/".join([w[:-1] for w in ws])) for s, ws in senses]

    rels = {}
    for s, w in senses:
        for rel_wnid, rel_name in s.ilrs:
            for s2, w2 in senses:
                if s2.wnid == rel_wnid:
                    rels[(w, w2)] = rel_name

    graph = nx.DiGraph()
    graph.add_edges_from(rels.keys())
    plt.figure(figsize=(15, 10))
    pos = nx.spring_layout(graph)
    nx.draw_networkx(graph, pos=pos, arrows=True, with_labels=True)
    nx.draw_networkx_edge_labels(graph, pos=pos, edge_labels=rels, label_pos=0.3)
    plt.show()
