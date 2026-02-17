$baseDir = "c:\Users\Sk Nooruddin\OneDrive\Desktop\raktSetu\stitch_assets"
if (!(Test-Path -Path $baseDir)) { New-Item -ItemType Directory -Force -Path $baseDir }

function Download-Asset {
    param ($folderName, $imgUrl, $htmlUrl)
    $dir = Join-Path $baseDir $folderName
    if (!(Test-Path -Path $dir)) { New-Item -ItemType Directory -Force -Path $dir }
    
    Invoke-WebRequest -Uri $imgUrl -OutFile (Join-Path $dir "screenshot.png")
    Invoke-WebRequest -Uri $htmlUrl -OutFile (Join-Path $dir "code.html")
}

Download-Asset "10_System_Notifications" "https://lh3.googleusercontent.com/aida/AOfcidXu9x1UILU53HA2uX75QXTOfzuylGyU7iNm_k_2j-8iUG75DjjK6jgroeVfpvqo88uADv1AGQhkjGmUzKnZLQyoSUb5x_vU_Mcv7UlhDSxdcQMqJkpHi29F8sof47EmOCnqg9tbVIELKjSq5VjC_pAfeQp-HeE1HVdDLjfMw_O3HXO3mTgo8L6cNqZx9ztYbZ2GNq4N8kLqrTSXKvpkT1bpRUWEYDzOZcU73ztvowUXro1yujZ97VDaxr0e" "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sX2RjYTQ5Y2U1NjM2NjRiMThiZWJiZDJjNjY1YmZmNmIxEgsSBxChvpbShBsYAZIBJAoKcHJvamVjdF9pZBIWQhQxMjk2MzM1Mzk3NDYxOTcyMzI3Nw&filename=&opi=89354086"
Download-Asset "11_Account_Locked_Warning" "https://lh3.googleusercontent.com/aida/AOfcidVn4jzJTZ5jpaR_r12VOmeHoCWdqPhK_MDpOpYiB4KdaOslUlAquJZPDzBakmedmWrq66zeolkTgv3gVzTMj6l3Ll2qwLbkTp3f7rOqIxxLdLJIuvEUwiBDp2P_h8VjaNbjlb6nF4pDtkIB4wLH6xe1QCMBSAx_DccUqrBZB2BXnTjmf4MFrbNFUM27OQR6UHegcX2kbHPwjleKCP-A6d-2hAOW1sEa9C8FrnEAgJcSTaXpqgL7Ii9OpwI" "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzc4OTRhNDk0N2FjMTQ0Njk4NzY4NmM1Mjk3Mjc1MTcwEgsSBxChvpbShBsYAZIBJAoKcHJvamVjdF9pZBIWQhQxMjk2MzM1Mzk3NDYxOTcyMzI3Nw&filename=&opi=89354086"
Download-Asset "12_Security_Change_Password" "https://lh3.googleusercontent.com/aida/AOfcidUlyIu5wLFLt277853wyEZJz3TiUhm1T5hoGVd7_M8DTNnqpJdj7Yhb9XiJX_KSYeqA951Ib7oDZA0l_zm4znf5_zeXIMbxtl8i8UaKPF6Z6bXj_YbDrpdVieVtOJlu60uk_FLBGTHAX6Sqh1x5US1ppL0bCIWBPwpFDOpEgFaWSLJf_TTkOCrq5Bdv5cAinq_hoOF4HrpP6-P-_VcuPZt0at3HZupQ9gsiSqJEWefj052q9UES383oN0R1" "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzE1NzQwZTdkM2YzNzRmYzM4OGVhNzNjNWMyMGU5MTAxEgsSBxChvpbShBsYAZIBJAoKcHJvamVjdF9pZBIWQhQxMjk2MzM1Mzk3NDYxOTcyMzI3Nw&filename=&opi=89354086"
Download-Asset "13_Loading_Empty_States" "https://lh3.googleusercontent.com/aida/AOfcidUoM0-0f2EMnXolBB2dFcGHP01u9XRMv2gbzLJrQs_xhPczXMwtcYDgK-b_LEDVivZDmOghM1TYFRKE-qSbUodYOl9XDO1eQ1Cidz8CS9SPXxrip__FLGngL-Fo_pJw7ecjeRokXy1rge1fq8dUXbe3dyn26Ha-lr1zQjUv4ZXCiMvXV-9zcD9zFOhL01kYYGZ3NWjNkFQ7HV-Hpgu1a1-l0rycUZneheWtj3YceGNYrLXZYJcbUM4ChDU" "https://contribution.usercontent.google.com/download?c=CgthaWRhX2NvZGVmeBJ8Eh1hcHBfY29tcGFuaW9uX2dlbmVyYXRlZF9maWxlcxpbCiVodG1sXzUwZDExOGRlYWQyMDQwNTM4YmIzODA4Y2QyMTI1OGUyEgsSBxChvpbShBsYAZIBJAoKcHJvamVjdF9pZBIWQhQxMjk2MzM1Mzk3NDYxOTcyMzI3Nw&filename=&opi=89354086"
