<picture>
  <source media="(prefers-reduced-motion: reduce)" srcset="assets/readme-header.png">
  <img src="assets/readme-header.gif" alt="Looksmaxx. I like this. More like that. This part is cool. Make it mine.">
</picture>

# looksmaxx

Looksmaxx your UI.

Give your agent a few sites you like, a screenshot, or a rough idea. Looksmaxx helps it put your taste into words, turn those words into design decisions, and build from them.

Keep giving feedback in your own words: “too busy,” “more like the first one,” “this part is cool.” The agent works out what to change.

## Use it

[Install the skill](#install), then try:

```text
Use looksmaxx to build my portfolio.
I like these sites: [links].
Help me figure out what I like about them, then build with that direction.
```

The language goes in `DESIGN.md`: a thesis, a few named qualities, and concrete choices for the build. Keep it with the project so another agent can pick up the same direction. If you only want the language, ask for it without a build.

## Examples

Four directions, with the thesis and words behind each design.

<table>
<tr>
<td width="50%" valign="top">
<strong>Kinetic Swiss</strong>
<p><strong>Confidence · Reactive</strong></p>
<p>Typography is the interface: large, bold, and responsive to your cursor.</p>
<a href="assets/examples/kinetic-swiss.gif"><img src="assets/examples/kinetic-swiss.gif" width="400" alt="Kinetic Swiss: variable type swells near the cursor, marquees move in opposing directions, and a colored tile changes shape on hover."></a>
</td>
<td width="50%" valign="top">
<strong>Editorial</strong>
<p><strong>Editorial · Spacious · Framed</strong></p>
<p>Give the images room, and let typography guide the reading.</p>
<a href="assets/examples/editorial.gif"><img src="assets/examples/editorial.gif" width="400" alt="Editorial: a hover responds, then scrolling reveals large serif type, generous space, fine rules, and architectural photography."></a>
</td>
</tr>
<tr>
<td width="50%" valign="top">
<strong>Shop</strong>
<p><strong>Playful · Tactile · Bold</strong></p>
<p>Put the objects on stage, and make browsing feel hands-on.</p>
<a href="assets/examples/shop.gif"><img src="assets/examples/shop.gif" width="400" alt="Shop: a record player lifts on hover, its finish changes through real controls, and scrolling reveals more products."></a>
</td>
<td width="50%" valign="top">
<strong>Product</strong>
<p><strong>Precise · Instrumented · Layered</strong></p>
<p>Make a complex system legible through visible structure and state.</p>
<a href="assets/examples/product.gif"><img src="assets/examples/product.gif" width="400" alt="Product: tabs switch between a topology diagram and waveform, then scrolling reveals more of the interface."></a>
</td>
</tr>
</table>

## Install

macOS / Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/aravind-n/looksmaxx/main/install.sh | sh
```

Windows / PowerShell:

```powershell
irm https://raw.githubusercontent.com/aravind-n/looksmaxx/main/install.ps1 | iex
```

The installers put the skill and its guides in `~/.agents/skills/looksmaxx`, with an optional Claude Code compatibility link. From a clone, run `sh ./install.sh` or `./install.ps1`.

Use it with a coding agent that can read local Markdown and work in your project. If your agent doesn't discover installed skills, ask it to read `/path/to/looksmaxx/SKILL.md` directly. Browser and image tools let it inspect references; without them, it can work from your observations and mark the gaps.
