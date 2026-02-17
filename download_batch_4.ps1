$baseDir = "c:\Users\Sk Nooruddin\OneDrive\Desktop\raktSetu\stitch_assets"
if (!(Test-Path -Path $baseDir)) { New-Item -ItemType Directory -Force -Path $baseDir }

function Download-Asset {
    param ($folderName, $imgUrl, $htmlUrl)
    $dir = Join-Path $baseDir $folderName
    if (!(Test-Path -Path $dir)) { New-Item -ItemType Directory -Force -Path $dir }
    
    Invoke-WebRequest -Uri $imgUrl -OutFile (Join-Path $dir "screenshot.png")
    Invoke-WebRequest -Uri $htmlUrl -OutFile (Join-Path $dir "code.html")
}

Download-Asset "14_Edit_Personal_Information" "https://lh3.googleusercontent.com/aida/AOfcidUi16jx1zb5xYfUntfiTxrSonRKsMmWQGs5926TE9e91VUZNjU9mvjgPVTzmuYQ1VUE-8UrVg8Ovo0LeyJ3lsZHG0EjyePOy-ZM7n4luVpzPTE-aGKBos0qIQRqFWySn4bD931tC70ZVaUuRztDIaqfsCmNJd4h4IuE9MMPbcUvopXnLalKAU1znINV6uw4YbBJ2n53VyU4hIOsx3Pos1No3CVlT50IRXQnh4AXtfWWuqdeeZJGHWI4Q2s" "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzM1OTBhZjBlMmFhZDQ4MzA5ZGFkZWIyYTM0ZjcyMWFjEgsSBxChvpbShBsYAZIBJAoKcHJvamVjdF9pZBIWQhQxMjk2MzM1Mzk3NDYxOTcyMzI3Nw&filename=&opi=89354086"
Download-Asset "15_Reset_Your_Password" "https://lh3.googleusercontent.com/aida/AOfcidVHp4T2JN5H0H5x5stftztXVhskxJWqBlGftT7wtbiVo2JjWCsEY6INTJEm3-LDukubYFlXYy0wRj5L3-Sigmt6iFC1MkU3tkB8u8zZPQwqzIvTrEpBu4tkt09R4Q7ZvR_pcM2iAavWKlXSwfEUHgCMYB3F5bzokgGEL42VK9nDqJhHvafwXd_xqdJWuwraPyo-_-wLFCumA2jEhIR6faRR226LjeBGB03r7ocy6Bc_Ijd7tFoT4j1rfopB" "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sX2U5ZmY5YjU3MDM3YjQxYzI4NmU0MjcxMmEwZGJjYmYyEgsSBxChvpbShBsYAZIBJAoKcHJvamVjdF9pZBIWQhQxMjk2MzM1Mzk3NDYxOTcyMzI3Nw&filename=&opi=89354086"
Download-Asset "16_Sign_In_to_RaktSetu" "https://lh3.googleusercontent.com/aida/AOfcidVudK5zCsWmBvIin8iLF9Wt932_SRjtEtXf2cW6GwrPTECe_aKvbrlkYQfetmyaGUuql2tLGBCev0vLUO5oYO7bCPEYTQv_2gib5qb3YWz3NDZvr6oo-gM019isECriZf80g7sXX_zit53q76ARJxk_x0dbFK22sYu23c9s3a2tz56dEnl70HyX0EL11lVNyoHPAvSWHDHHw1OaIWYfPnshiRMebg0XXMcLhNUpc_-zLSSz-2QqGLKt4vPx" "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sX2U5YTcyZTU1OGNmMTQ2Y2NiMWE4M2U0MzU3MTZjNWRmEgsSBxChvpbShBsYAZIBJAoKcHJvamVjdF9pZBIWQhQxMjk2MzM1Mzk3NDYxOTcyMzI3Nw&filename=&opi=89354086"
