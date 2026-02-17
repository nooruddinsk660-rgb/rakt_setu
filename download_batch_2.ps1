$baseDir = "c:\Users\Sk Nooruddin\OneDrive\Desktop\raktSetu\stitch_assets"
if (!(Test-Path -Path $baseDir)) { New-Item -ItemType Directory -Force -Path $baseDir }

function Download-Asset {
    param ($folderName, $imgUrl, $htmlUrl)
    $dir = Join-Path $baseDir $folderName
    if (!(Test-Path -Path $dir)) { New-Item -ItemType Directory -Force -Path $dir }
    
    Invoke-WebRequest -Uri $imgUrl -OutFile (Join-Path $dir "screenshot.png")
    Invoke-WebRequest -Uri $htmlUrl -OutFile (Join-Path $dir "code.html")
}

Download-Asset "06_HR_Volunteer_Analytics" "https://lh3.googleusercontent.com/aida/AOfcidWEle2_eWnae1M2lcmDIjWQiT50kQd0gvBxwMaA5miLKv8AxkEElUKH1MECdJj5vKtgZkpi3urCnbZcFaAanwSJvCjK5MmtJ0YmjZ4kyEgzvU10yq4_bpoJxG_tjlHvcWLyyD3YvPj9I2012BXx5OLnz1YTaZdLs4bpWjT1IdlIN9WMa6Rq6nPGNqGFDkPRYnx-jGLy_Xhv-hrCQSp1oNr2Ao_wIapES4XiEsi3Lr_6IlhbthH3g2Jxnvs" "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sX2M3Njg4YmEwM2I0NjQzZTRiYzA2M2JkYjdkZDBlNWRiEgsSBxChvpbShBsYAZIBJAoKcHJvamVjdF9pZBIWQhQxMjk2MzM1Mzk3NDYxOTcyMzI3Nw&filename=&opi=89354086"
Download-Asset "07_Helpline_Case_Details" "https://lh3.googleusercontent.com/aida/AOfcidUOdDvJdjn7L_jHkQSKwnQUwE1jrb1R1wq7169O9-M46bo8v-tch6HU_cI-RNoyL-TvuLbDLuGYHsY0-21_lQZoNKH3VXMy80u8wfYwOfzksA5e36PGw_qikm-xfXYPkwJsTtpFWbYWzcvQJvFoltbBr2n1w8jvu_jV-jTr2guYP55xqHb2c1FmZ9mmlvUD8KH3hwnZdKw3ocLqMTBezBIRa5TJEpZF_ZZHSfRyAFwnP_Yhum0v_2GplmqC" "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sX2UwNjc5NGIwYTdiMDQ0OThhMjcwZTIzNmY5NDBjNzVjEgsSBxChvpbShBsYAZIBJAoKcHJvamVjdF9pZBIWQhQxMjk2MzM1Mzk3NDYxOTcyMzI3Nw&filename=&opi=89354086"
Download-Asset "08_Manager_Operations_Hub" "https://lh3.googleusercontent.com/aida/AOfcidXhfnw3SS0nBNFJX6LJVmMYiN03dfaQPny4QAth0Rl4F4oI4YxAXm1KZZG1Y8qrNIwIYIZrQzOtA3f1BxJC4c7UOImF-Ev5pcOYkDA5rl7ImTs6NSTmEbFgVfGinZZDJsz2D1mGeapj-JQNNu3SteOt3OMYcSGV0oGO3Ip8WspUU2EAPlZlAHGqxcP8kq8r7IE3FC9-z36nIL1Iu20lZAxhgXRPifa3gp9-4e5k-T0pHHpYbqoQRKLuDp4" "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzhiZjk4OGZkM2RiZTQxYTU4OGVjNTFlZjJhYTM3NzkxEgsSBxChvpbShBsYAZIBJAoKcHJvamVjdF9pZBIWQhQxMjk2MzM1Mzk3NDYxOTcyMzI3Nw&filename=&opi=89354086"
Download-Asset "09_User_Profile_Settings" "https://lh3.googleusercontent.com/aida/AOfcidUdTgZb6pGePM1NJkd5aQCHLBsNq9dnhqxMNaL-sKIbsNdDrGvudqQG5PrQxMUYPCsfnmDzCeYW0TP-fBZodhs6mNPVhyK4qNiNaIqsLfr9JR7K25XAI-KPvDOxdCZQix4AA63cPPLpTJgoKyO7-WX-nHkyzahY5Wa5KnSh5Yeg1BO9RvJu8ynCu106MJ7-TXao8EgB2Z47w2YW7eAHEK0P-S354_zK2hg3j6UkyWjjq8MuukZ2ehub_mja" "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sX2MwNmFmYTYzOGJhODQ0OTdhMDRiZWE1ZmE2ZmIwZGMzEgsSBxChvpbShBsYAZIBJAoKcHJvamVjdF9pZBIWQhQxMjk2MzM1Mzk3NDYxOTcyMzI3Nw&filename=&opi=89354086"
