#!/bin/bash

# 設定專案目錄
PROJECT_DIR=${1:-"."}  # 預設為當前目錄

# 設定輸出的檔案
OUTPUT_FILE="project_prompt.xml"

# 定義要排除的文件或模式，類似 .gitignore
# 用空格分隔多個文件或模式
IGNORE_FILES=".gitignore *.log poetry.lock project_prompt.xml __init__.py"

# 清空輸出的檔案，並寫入 XML header
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > $OUTPUT_FILE
echo "<project>" >> $OUTPUT_FILE

# 切換到專案目錄
cd $PROJECT_DIR || { echo "Invalid project directory."; exit 1; }

# 檢查是否有 .gitignore 檔案
if [ -f ".gitignore" ]; then
    echo "Using .gitignore rules to ignore files..."
else
    echo "No .gitignore found, proceeding without ignoring files..."
fi

# 列出符合 .gitignore 規則的文件，並排除自定義的忽略文件
echo "  <structure>" >> $OUTPUT_FILE
git ls-files | while read -r file; do
    # 檢查文件是否在忽略列表中
    ignore=false
    for pattern in $IGNORE_FILES; do
        if [[ "$file" == $pattern || "$file" == *$pattern ]]; then
            ignore=true
            break
        fi
    done
    # 如果不在忽略列表中，將文件加入輸出
    if [ "$ignore" = false ]; then
        echo "    <file>$file</file>" >> $OUTPUT_FILE
    fi
done
echo "  </structure>" >> $OUTPUT_FILE

# 加入空行分隔
echo "  <contents>" >> $OUTPUT_FILE

# 遞迴顯示每個未被忽略檔案的完整內容，並用 XML 包裝，根據忽略文件過濾
git ls-files | while read -r file
do
    # 檢查文件是否在忽略列表中
    ignore=false
    for pattern in $IGNORE_FILES; do
        if [[ "$file" == $pattern || "$file" == *$pattern ]]; then
            ignore=true
            break
        fi
    done
    # 如果不在忽略列表中，則將文件內容寫入 XML
    if [ "$ignore" = false ]; then
        echo "    <file name=\"$file\">" >> $OUTPUT_FILE
        echo "      <content><![CDATA[" >> $OUTPUT_FILE
        cat "$file" >> $OUTPUT_FILE
        echo "      ]]></content>" >> $OUTPUT_FILE
        echo "    </file>" >> $OUTPUT_FILE
    fi
done

# 結束 XML
echo "  </contents>" >> $OUTPUT_FILE
echo "</project>" >> $OUTPUT_FILE

echo "XML prompt generated in $OUTPUT_FILE."
