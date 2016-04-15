comparevk
========
Сравнение аудитории сообществ VK

## Сборка

Для сборки понадобятся:
gulp, coffeescript, riot, gulp-concat, gulp-uglify, gulp-wait

## execute.massfetch

```javascript
var arr = [];
var hash = { items: [] };
var where = Args.where;
var start = parseInt(Args.start);
var fields = Args.fields;
var end = 25000;
var i = 0;

while(i != end) {
    var offset = start + i;
    var a = API.groups.getMembers({ "group_id": where, "offset": offset, "fields": fields });
    hash.count = a.count;
    if (a.items.length == 0) {
        i = end;
    } else {
        hash.items = hash.items + a.items;
        i = i + 1000;
    }
}

return hash;
```
