require "solidus_starter_frontend_spec_helper"

RSpec.describe TaxonsTreeComponent, type: :component do
  let(:taxon_without_descendants) { create(:taxon, children: []) }

  let(:taxon_with_descendants) do
    root = create(:taxon)

    children = [
      create(:taxon, name: 'child 1', parent: root),
      create(:taxon, name: 'child 2', parent: root)
    ]

    # child 1 grandchild
    create(:taxon, name: 'grandchild 1', parent: children[0])

    root
  end

  let(:title) { 'some_title' }
  let(:root_taxon) { taxon_with_descendants }
  let(:current_taxon) { nil }
  let(:max_level) { 1 }
  let(:current_item_classes) { 'underline' }

  let(:local_assigns) do
    {
      title: title,
      root_taxon: root_taxon,
      current_taxon: current_taxon,
      max_level: max_level,
      current_item_classes: current_item_classes
    }
  end

  context 'when rendered' do
    before do
      render_inline(described_class.new(**local_assigns))
    end

    describe 'concerning max_level and root_taxon' do
      context 'when the max level is less than 1' do
        let(:max_level) { 0 }

        it 'does not render any items' do
          expect(page.all('li')).to be_empty
        end
      end

      context 'when the max level is 1' do
        let(:max_level) { 1 }

        context 'when the root taxon has no descendants' do
          let(:root_taxon) { taxon_without_descendants }

          it 'does not render any items' do
            expect(page.all('li')).to be_empty
          end
        end

        context 'when the root taxon has descendants' do
          let(:root_taxon) { taxon_with_descendants }

          it "renders a list of the root taxon's children" do
            expect(page.all('li').map(&:text)).to match(['child 1', 'child 2'])
          end
        end
      end

      context 'when the max level is greater than 1' do
        let(:max_level) { 2 }

        context 'when the root taxon has no descendants' do
          let(:root_taxon) { taxon_without_descendants }

          it 'does not render any items' do
            expect(page.all('li')).to be_empty
          end
        end

        context 'when the root taxon has descendants' do
          let(:root_taxon) { taxon_with_descendants }

          it "renders a list of the root taxon's descendants" do
            # child 1's text includes the text of the grandchild 1.
            expect(page.all('li').map(&:text)).to match(['child 1grandchild 1', 'grandchild 1', 'child 2'])
          end
        end
      end
    end

    describe 'concerning current_taxon' do
      context 'when current_taxon is not provided' do
        let(:current_taxon) { nil }

        it 'does not mark any taxon as "current"' do
          expect(page).to have_no_css('li', class: current_item_classes)
        end
      end

      context 'when current_taxon is provided' do
        context 'when current_taxon matches a descendant' do
          let(:current_taxon) { root_taxon.children.first }

          it 'marks the current taxon as "current"' do
            expect(page.find('li', class: current_item_classes)).to have_text('child 1')
          end
        end

        context 'when current_taxon does not match any descendant' do
          let(:current_taxon) { create(:taxon) }

          it 'does not mark any taxon as "current"' do
            expect(page).to have_no_css('li', class: current_item_classes)
          end
        end
      end
    end

    describe 'concerning title' do
      let(:base_class) { 'some_base_class' }

      context 'when a title is provided' do
        let(:title) { 'some title' }

        it 'renders the title' do
          expect(page).to have_content('some title')
        end
      end

      context 'when there is no title provided' do
        let(:title) { nil }

        it 'does not render the title' do
          expect(page).to_not have_content('some title')
        end
      end
    end
  end
end
