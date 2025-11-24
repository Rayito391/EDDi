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

const baseParagraphs = [
  'Por medio del presente se hace constar que la nombre docente, elaboró durante el semestre, un recurso educativo digital afín al contenido de la asignatura de Fundamentos de programación del programa educativo de Ingeniería en sistemas computacionales, aprobado y utilizado por la misma academia, contando con la rúbrica de evaluación correspondiente.',
  'Se extiende la presente en la ciudad de Culiacán, Sinaloa',
];

// Si quieres personalizar un documento en particular, agrega aquí su id con paragraphs propios.
const docTemplates: Record<number, TemplateRenderer> = {
  // 4: ({ titulo }) => ({
  //   titleLines: [titulo || 'Documento 4'],
  //   paragraphs: ['Párrafo 1 personalizado', 'Párrafo 2 personalizado'],
  // }),
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
      ...baseParagraphs,
    ].filter(Boolean),
  };
}
