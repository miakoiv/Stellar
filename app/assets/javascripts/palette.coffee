class Palette
  @palettes =
    qualitative: ['66ccee', '4477aa', 'aa3377', 'ee6677', 'ccbb44', '228833']
    sequential: ['d6c1de', 'b178a6', '882e72', '1965b0', '5289c7', '7bafde', '4eb265',
      '90c987', 'cae0ab', 'f7ee55', 'f6c141', 'f1932d', 'e86d1c', 'dc050c']

  @mix: (ink, opacity) ->
    d = parseInt ink, 16
    [r, g, b] = [d >> 16 & 255, d >> 8 & 255, d & 255]
    "rgba(#{r},#{g},#{b},#{opacity})"

  @generate: (type, opacity) ->
    @mix(ink, opacity) for ink in @palettes[type]

  @pick: (type, idx, opacity) ->
    @mix(@palettes[type][idx], opacity)

(exports ? this).Palette = Palette
