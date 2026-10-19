"""
Генерация иконки ContrasDush — градиент + капля.
"""
from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

def make_icon(size: int = 1024) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Градиент (синий → голубой)
    for y in range(size):
        ratio = y / size
        r = int(59 + (147 - 59) * ratio)
        g = int(130 + (197 - 130) * ratio)
        b = int(246 + (253 - 246) * ratio)
        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))

    # Скруглённые углы (маска)
    mask = Image.new("L", (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    radius = int(size * 0.22)
    mask_draw.rounded_rectangle(
        [(0, 0), (size, size)], radius=radius, fill=255
    )
    img.putalpha(mask)

    # Капля (простая)
    drop_size = int(size * 0.5)
    drop_x = (size - drop_size) // 2
    drop_y = (size - drop_size) // 2 + int(size * 0.05)

    drop = Image.new("RGBA", (drop_size, drop_size), (0, 0, 0, 0))
    drop_draw = ImageDraw.Draw(drop)

    # Круг капли
    circle_r = drop_size // 2
    drop_draw.ellipse(
        [(0, 0), (drop_size, drop_size)],
        fill=(255, 255, 255, 255)
    )

    # Треугольник сверху (хвост капли)
    drop_draw.polygon(
        [
            (drop_size // 2, 0),
            (drop_size // 2 - circle_r // 2, circle_r // 2),
            (drop_size // 2 + circle_r // 2, circle_r // 2),
        ],
        fill=(255, 255, 255, 255)
    )

    img.paste(drop, (drop_x, drop_y), drop)
    return img


def main():
    base = Path(__file__).parent
    icons_dir = base / "ContrasDush" / "Assets.xcassets" / "AppIcon.appiconset"
    icons_dir.mkdir(parents=True, exist_ok=True)

    # 1024×1024 — основная
    icon = make_icon(1024)
    icon.save(icons_dir / "icon-1024.png")

    # Contents.json
    contents = {
        "images": [
            {
                "filename": "icon-1024.png",
                "idiom": "universal",
                "platform": "ios",
                "size": "1024x1024"
            }
        ],
        "info": {"author": "xcode", "version": 1}
    }

    import json
    with open(icons_dir / "Contents.json", "w") as f:
        json.dump(contents, f, indent=2)

    print(f"OK: иконка создана в {icons_dir}")


if __name__ == "__main__":
    main()