from pathlib import Path
import re
manifest=Path('android/app/src/main/AndroidManifest.xml')
if not manifest.exists(): raise SystemExit('Execute flutter create --platforms=android --org com.roxoshop .')
s=manifest.read_text()
s=re.sub(r'\s*<meta-data\s+android:name=["\']com\.google\.android\.gms\.ads\.APPLICATION_ID["\'][^>]*?/?>','',s)
for permission in ('android.permission.INTERNET','android.permission.ACCESS_NETWORK_STATE','com.google.android.gms.permission.AD_ID'):
    if permission not in s: s=s.replace('<application',f'<uses-permission android:name="{permission}" />\n    <application',1)
s=s.replace('android:label="roxo_shop"','android:label="Roxo Shop"')
manifest.write_text(s)
root=Path('android/app')
files=list(root.glob('build.gradle*'))
if not files: raise SystemExit('Gradle app-level ausente')
p=files[0]; x=p.read_text()
if 'unityads-adapter' not in x:
    if p.suffix=='.kts':
        deps='''\ndependencies {\n    implementation("com.unity3d.ads-mediation:unityads-adapter:5.15.0")\n    implementation("com.google.android.gms:play-services-ads-identifier:18.2.0")\n    implementation("com.google.android.gms:play-services-appset:16.1.0")\n}\n'''
    else:
        deps="""\ndependencies {\n    implementation 'com.unity3d.ads-mediation:unityads-adapter:5.15.0'\n    implementation 'com.google.android.gms:play-services-ads-identifier:18.2.0'\n    implementation 'com.google.android.gms:play-services-appset:16.1.0'\n}\n"""
    p.write_text(x+deps)
settings=Path('android/settings.gradle.kts')
if settings.exists():
    x=settings.read_text()
    x=re.sub(r'id\("org.jetbrains.kotlin.android"\) version "[^"]+"', 'id("org.jetbrains.kotlin.android") version "2.2.20"', x)
    settings.write_text(x)

# Assinatura release: usa somente credenciais fornecidas pelo Codemagic.
# Nunca grave senhas ou o keystore no repositorio.
if p.suffix == '.kts':
    x = p.read_text()
    marker = 'signingConfigs {'
    if 'CM_KEYSTORE_PATH' not in x:
        signing = '''
    signingConfigs {
        create("release") {
            val ksPath = System.getenv("CM_KEYSTORE_PATH")
            if (!ksPath.isNullOrBlank()) {
                storeFile = file(ksPath)
                storePassword = System.getenv("CM_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("CM_KEY_ALIAS")
                keyPassword = System.getenv("CM_KEY_PASSWORD")
            }
        }
    }
    '''
        x = re.sub(r'android\s*\{', lambda m: m.group(0) + signing, x, count=1)
        x = x.replace('signingConfig = signingConfigs.getByName("debug")', 'signingConfig = signingConfigs.getByName("release")')
        if 'signingConfig = signingConfigs.getByName("release")' not in x:
            raise SystemExit('Nao foi encontrado buildTypes.release no template Android; confira o log.')
        p.write_text(x)
else:
    if 'CM_KEYSTORE_PATH' not in x:
        raise SystemExit('Template Gradle Groovy exige configurar assinatura release manualmente.')

print('Android preparado para LevelPlay + Unity Ads, sem AdMob SDK.')
