#3 Znajdź wszystkie znaczenia rzeczownika szkoda oraz wymień ich synonimy (jeśli posiadają).
```python
[x.toString() for x in ex7.szkoda_meanings(q)]
['PLWN-00003675-n  {strata:1, utrata:1, szkoda:2, uszczerbek:1}  ()', 'PLWN-00006533-n  {szkoda:1}  (brak danych)']
```

#4 Znajdź domknięcie przechodnie relacji hiperonimi dla pierwszego znaczenia wyrażenia wypadek drogowy i przedstaw je w postaci grafu skierowanego.
```python
ex7.wypadek_drogowy_hypernym(q)
```
![Graf relacji hiperonimii](wypadek_graph.png)

#5 Znajdź bezpośrednie hiponimy rzeczownika wypadek1.
```python
[x.toString() for x in ex7.wypadek_hyponyms(q)]
['PLWN-00001284-n  {zderzenie:2, kraksa:1}  ()', 'PLWN-00006486-n  {kolizja:2}  ()', 'PLWN-00016131-n  {karambol:1}  ()', 'PLWN-00034688-n  {zawał:2}  ()', 'PLWN-00034689-n  {tąpnięcie:1}  ()', 'PLWN-00241026-n  {kapotaż:1}  ()', 'PLWN-00258639-n  {wykolejenie:2}  ()', 'PLWN-00389170-n  {zakrztuszenie:1, zachłyśnięcie:1, aspiracja:3}  ()', 'PLWN-00410901-n  {wypadek komunikacyjny:1}  ()', 'PLWN-00411618-n  {katastrofa budowlana:1}  ()', 'PLWN-00436137-n  {wypadek jądrowy:1}  ()']
```

#6 Znajdź hiponimy drugiego rzędu dla rzeczownika wypadek1.
```python
[x.toString() for x in ex7.wypadek_hyponyms(q, row=2)]
['PLWN-00235346-n  {czołówka:9, zderzenie czołowe:1}  ()', 'PLWN-00471555-n  {stłuczka:1}  ()', 'PLWN-00441365-n  {kolizja drogowa:1}  ()', 'PLWN-00037295-n  {obwał:1}  ()', 'PLWN-00410902-n  {wypadek drogowy:1}  ()']
```
