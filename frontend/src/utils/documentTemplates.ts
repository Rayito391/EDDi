export type RenderedDocument = {
  titleLines: string[];
  paragraphs: string[];
};

type RenderCtx = {
  docenteNombre: string;
  titulo: string;
  folio?: string;
  fecha?: string;
  logoLeft?: string;
};

type TemplateRenderer = (ctx: RenderCtx) => RenderedDocument;

const docTemplates: Record<number, TemplateRenderer> = {
  1: ({ titulo }) => ({
    titleLines: [titulo || 'Documento 1'],
    paragraphs: ['Párrafo 1 del documento 1', 'Párrafo 2 del documento 1'],
  }),
  2: ({ titulo }) => ({
    titleLines: [titulo || 'Documento 2'],
    paragraphs: ['Párrafo 1 del documento 2', 'Párrafo 2 del documento 2'],
  }),
  3: ({ titulo }) => ({
    titleLines: [titulo || 'Documento 3'],
    paragraphs: ['Párrafo 1 del documento 3', 'Párrafo 2 del documento 3'],
  }),
};

export function renderDocumentContent(
  templateId: number,
  ctx: RenderCtx
): RenderedDocument {
  const renderer = docTemplates[templateId];
  if (renderer) return renderer(ctx);
  return {
    titleLines: [ctx.titulo || 'Documento'],
    paragraphs: [
      `Párrafo 1 genérico para ${ctx.docenteNombre.toUpperCase()}`,
      `Párrafo 2 genérico`,
      ctx.folio ? `Folio interno: ${ctx.folio}` : '',
      ctx.fecha ? `Fecha: ${ctx.fecha}` : '',
    ].filter(Boolean),
  };
}
