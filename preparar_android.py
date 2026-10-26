# Executar apos: flutter create --platforms=android --org com.roxoshop .
from pathlib import Path
p = Path('android/app/src/main/AndroidManifest.xml')
if not p.exists():
    raise SystemExit('Manifest nao encontrado. Execute flutter create antes.')
s = p.read_text(encoding='utf-8')
marker = 'com.google.android.gms.ads.APPLICATION_ID'
if marker not in s:
    insert = '<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="ca-app-pub-3940256099942544~3347511713" />'
    s=s.replace('<application', '<application', 1)
    start=s.index('<application')
    end=s.index('>', start)
    s=s[:end+1]+'\n        '+insert+s[end+1:]
    p.write_text(s, encoding='utf-8')
# WebView precisa de acesso a internet no app Android, inclusive em release.
s=p.read_text(encoding='utf-8')
if 'android.permission.INTERNET' not in s:
    s=s.replace('<application', '<uses-permission android:name="android.permission.INTERNET" />\n    <application', 1)
    p.write_text(s, encoding='utf-8')
strings = Path('android/app/src/main/res/values/strings.xml')
strings.parent.mkdir(parents=True,exist_ok=True)
strings.write_text('<resources><string name="app_name">Roxo Shop</string></resources>\n',encoding='utf-8')
# Adjust Android label reliably.
s=p.read_text(encoding='utf-8').replace('android:label="roxo_shop"','android:label="Roxo Shop"').replace('android:label="shop_roxo"','android:label="Roxo Shop"')
p.write_text(s,encoding='utf-8')
print('Android Manifest configurado com ID OFICIAL DE TESTE do AdMob.')
