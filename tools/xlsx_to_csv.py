"""
XLSX 轉 CSV 轉換工具
使用方式：python tools/xlsx_to_csv.py <輸入檔案.xlsx> [輸出目錄]
"""

import sys
import os
import pandas as pd
from pathlib import Path

def convert_xlsx_to_csv(xlsx_file, output_dir=None):
    """
    將 XLSX 檔案轉換為 CSV
    
    Args:
        xlsx_file: XLSX 檔案路徑
        output_dir: 輸出目錄（可選，預設為與 XLSX 檔案同目錄）
    """
    try:
        # 檢查檔案是否存在
        if not os.path.exists(xlsx_file):
            print(f"錯誤：找不到檔案 {xlsx_file}")
            return False
        
        # 讀取 XLSX 檔案
        print(f"正在讀取 {xlsx_file}...")
        xlsx_path = Path(xlsx_file)
        
        # 讀取所有工作表
        excel_file = pd.ExcelFile(xlsx_file)
        sheet_names = excel_file.sheet_names
        
        print(f"找到 {len(sheet_names)} 個工作表：{', '.join(sheet_names)}")
        
        # 設定輸出目錄
        if output_dir:
            output_path = Path(output_dir)
        else:
            output_path = xlsx_path.parent
        
        output_path.mkdir(parents=True, exist_ok=True)
        
        # 轉換每個工作表
        converted_files = []
        for sheet_name in sheet_names:
            print(f"正在轉換工作表：{sheet_name}...")
            
            # 讀取工作表
            df = pd.read_excel(xlsx_file, sheet_name=sheet_name)
            
            # 生成輸出檔名
            # 將工作表名稱中的特殊字元替換為安全字元
            safe_sheet_name = sheet_name.replace('/', '_').replace('\\', '_').replace(':', '_')
            csv_filename = xlsx_path.stem + '_' + safe_sheet_name + '.csv'
            csv_path = output_path / csv_filename
            
            # 儲存為 CSV（使用 UTF-8 編碼，支援中文）
            df.to_csv(csv_path, index=False, encoding='utf-8-sig')
            
            print(f"  ✓ 已轉換：{csv_path}")
            converted_files.append(str(csv_path))
        
        print(f"\n轉換完成！共轉換 {len(converted_files)} 個檔案：")
        for file in converted_files:
            print(f"  - {file}")
        
        return True
        
    except ImportError:
        print("錯誤：需要安裝 pandas 和 openpyxl")
        print("請執行：pip install pandas openpyxl")
        return False
    except Exception as e:
        print(f"錯誤：{str(e)}")
        return False

def main():
    if len(sys.argv) < 2:
        print("XLSX 轉 CSV 轉換工具")
        print("\n使用方式：")
        print("  python tools/xlsx_to_csv.py <輸入檔案.xlsx> [輸出目錄]")
        print("\n範例：")
        print("  python tools/xlsx_to_csv.py data.xlsx")
        print("  python tools/xlsx_to_csv.py data.xlsx output/")
        print("\n注意：需要先安裝依賴：pip install pandas openpyxl")
        sys.exit(1)
    
    xlsx_file = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else None
    
    success = convert_xlsx_to_csv(xlsx_file, output_dir)
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()

