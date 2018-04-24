import os
from sklearn.svm import LinearSVC
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn import metrics

case_types = ['C', 'U', 'K', 'G', 'P', 'R', 'W', 'Am']

base_dir = "../dump/ex6/cases"
# base_dir = "../dump/ex6/cases_bf"


def read_judgments(cat, purpose):
    for filename in os.listdir(os.path.join(base_dir, cat, purpose)):
        with open(os.path.join(base_dir, cat, purpose, filename), 'r') as f:
            yield f.read()


x_train = []
y_train = []
x_test = []
y_test = []
for category in case_types:
    train_judgments = list(read_judgments(category, "train"))[:300]
    test_judgments = list(read_judgments(category, "test"))[:30]
    x_train = x_train + train_judgments
    y_train = y_train + [category] * len(train_judgments)
    x_test = x_test + test_judgments
    y_test = y_test + [category] * len(test_judgments)


vectorizer = TfidfVectorizer()
x_train_vect = vectorizer.fit_transform(x_train)
x_test_vec = vectorizer.transform(x_test)

total_real = []
total_pred = []

for ct in case_types:
    y_train_vect = [1 if ct == cat else 0 for cat in y_train]
    y_test_vect = [1 if ct == cat else 0 for cat in y_test]

    model = LinearSVC()
    model.fit(x_train_vect, y_train_vect)

    pred = model.predict(x_test_vec)

    results = metrics.precision_recall_fscore_support(y_test_vect, pred, average='binary')
    precision, recall, f1, _support = results

    total_real = total_real + y_test_vect
    total_pred = total_pred + list(pred)

    print("Category {}:\n\tprecision\t{}\n\trecall\t\t{}\n\tf1 score\t{}\n\n".format(ct, precision, recall, f1))

micro_precision, micro_recall, micro_f1, _support =\
    metrics.precision_recall_fscore_support(total_real, total_pred, average='micro')
macro_precision, macro_recall, macro_f1, _support =\
    metrics.precision_recall_fscore_support(total_real, total_pred, average='macro')

print("Micro avg\n\tprecision\t{}\n\trecall\t\t{}\n\tf1 score\t{}\n\n".format(micro_precision, micro_recall, micro_f1))
print("Macro avg\n\tprecision\t{}\n\trecall\t\t{}\n\tf1 score\t{}\n\n".format(macro_precision, macro_recall, macro_f1))

